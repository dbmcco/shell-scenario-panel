#!/bin/bash
# Dialog logging for moderator-user interactions (RL training data)

# Usage: log_dialog SCENARIO_ID INTERACTION_TYPE JSON_DATA
log_dialog() {
    local SCENARIO_ID=$1
    local INTERACTION_TYPE=$2
    local JSON_DATA=$3

    if [ -z "$SCENARIO_ID" ] || [ -z "$INTERACTION_TYPE" ] || [ -z "$JSON_DATA" ]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: log_dialog SCENARIO_ID INTERACTION_TYPE JSON_DATA" >&2
        return 1
    fi

    local LOG_FILE="scenarios/active/${SCENARIO_ID}/moderator_dialog.jsonl"
    local SCENARIO_DIR="scenarios/active/${SCENARIO_ID}"

    # Ensure scenario directory exists
    if [ ! -d "$SCENARIO_DIR" ]; then
        echo "Error: Scenario directory not found: $SCENARIO_DIR" >&2
        return 1
    fi

    # Add timestamp if not present
    if ! echo "$JSON_DATA" | jq -e '.timestamp' > /dev/null 2>&1; then
        local TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        JSON_DATA=$(echo "$JSON_DATA" | jq --arg ts "$TIMESTAMP" '. + {timestamp: $ts}')
    fi

    # Add scenario_id and interaction_type if not present
    JSON_DATA=$(echo "$JSON_DATA" | jq \
        --arg sid "$SCENARIO_ID" \
        --arg itype "$INTERACTION_TYPE" \
        '. + {scenario_id: $sid, interaction_type: $itype}')

    # Append to log file (one JSON object per line)
    echo "$JSON_DATA" >> "$LOG_FILE"

    echo "✅ Dialog logged: $INTERACTION_TYPE"
}

# Helper: Create checkpoint interaction entry
log_checkpoint() {
    local SCENARIO_ID=$1
    local PHASE=$2
    local ROUND=$3
    local MODERATOR_MSG=$4
    local USER_RESPONSE=$5
    local USER_DECISION=$6
    local OUTCOME=$7

    local JSON=$(jq -n \
        --arg phase "$PHASE" \
        --argjson round "$ROUND" \
        --arg mod_msg "$MODERATOR_MSG" \
        --arg user_resp "$USER_RESPONSE" \
        --arg user_dec "$USER_DECISION" \
        --arg outcome "$OUTCOME" \
        '{
            phase: $phase,
            round: $round,
            moderator_message: {
                content: $mod_msg,
                message_type: "checkpoint_prompt"
            },
            user_response: {
                content: $user_resp,
                response_type: "feedback"
            },
            user_decision: {
                decision: $user_dec
            },
            outcome: {
                checkpoint_successful: true,
                feedback_captured: ($user_resp != "looks good" and $user_resp != "")
            }
        }')

    log_dialog "$SCENARIO_ID" "checkpoint" "$JSON"
}

# Helper: Create validation interaction entry
log_validation() {
    local SCENARIO_ID=$1
    local PHASE=$2
    local DOCUMENT=$3
    local USER_RESPONSE=$4
    local VALIDATED=$5

    local JSON=$(jq -n \
        --arg phase "$PHASE" \
        --arg doc "$DOCUMENT" \
        --arg user_resp "$USER_RESPONSE" \
        --arg validated "$VALIDATED" \
        '{
            phase: $phase,
            moderator_message: {
                content: ("Please validate: " + $doc),
                message_type: "validation_request"
            },
            user_response: {
                content: $user_resp,
                response_type: "validation"
            },
            outcome: {
                user_validated: ($validated == "true"),
                phase_completed: ($validated == "true")
            }
        }')

    log_dialog "$SCENARIO_ID" "validation_request" "$JSON"
}

# Helper: Create user question entry
log_user_question() {
    local SCENARIO_ID=$1
    local USER_QUESTION=$2
    local MODERATOR_RESPONSE=$3
    local RESOLVED=$4

    local JSON=$(jq -n \
        --arg user_q "$USER_QUESTION" \
        --arg mod_resp "$MODERATOR_RESPONSE" \
        --arg resolved "$RESOLVED" \
        '{
            user_message: {
                content: $user_q,
                message_type: "question"
            },
            moderator_response: {
                content: $mod_resp,
                response_type: "clarification"
            },
            outcome: {
                question_resolved: ($resolved == "true")
            }
        }')

    log_dialog "$SCENARIO_ID" "user_question" "$JSON"
}

# Helper: Create scenario completion entry
log_scenario_completion() {
    local SCENARIO_ID=$1
    local TOTAL_CHECKPOINTS=$2
    local TOTAL_CONSULTATIONS=$3
    local COMPLETION_HOURS=$4
    local USER_SATISFACTION=$5

    local JSON=$(jq -n \
        --argjson checkpoints "$TOTAL_CHECKPOINTS" \
        --argjson consultations "$TOTAL_CONSULTATIONS" \
        --arg hours "$COMPLETION_HOURS" \
        --arg satisfaction "$USER_SATISFACTION" \
        '{
            scenario_metadata: {
                total_checkpoints: $checkpoints,
                total_specialist_consultations: $consultations,
                completion_time_hours: $hours,
                user_satisfaction_overall: $satisfaction,
                scenario_successful: true
            }
        }')

    log_dialog "$SCENARIO_ID" "scenario_completion" "$JSON"
}

# Export functions for use in other scripts
export -f log_dialog
export -f log_checkpoint
export -f log_validation
export -f log_user_question
export -f log_scenario_completion

# If called directly, provide usage
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 3 ]; then
        echo "Dialog Logging Utility"
        echo ""
        echo "Usage:"
        echo "  log_dialog SCENARIO_ID INTERACTION_TYPE JSON_DATA"
        echo ""
        echo "Helper functions:"
        echo "  log_checkpoint SCENARIO_ID PHASE ROUND MODERATOR_MSG USER_RESPONSE USER_DECISION OUTCOME"
        echo "  log_validation SCENARIO_ID PHASE DOCUMENT USER_RESPONSE VALIDATED"
        echo "  log_user_question SCENARIO_ID USER_QUESTION MODERATOR_RESPONSE RESOLVED"
        echo "  log_scenario_completion SCENARIO_ID TOTAL_CHECKPOINTS TOTAL_CONSULTATIONS HOURS SATISFACTION"
        exit 1
    fi

    log_dialog "$@"
fi
