#!/bin/bash

# Dialog Recording Hook (UserPromptSubmit)
# Captures user messages via stdin and logs to moderator_dialog.jsonl
# Triggers on each user prompt submission

SCRIPT_DIR="$(dirname "$0")"

# Read JSON input from stdin (Claude Code provides this)
INPUT_JSON=$(cat)

# Extract prompt from input
USER_PROMPT=$(echo "$INPUT_JSON" | jq -r '.prompt // empty' 2>/dev/null)

# Skip if no prompt
if [ -z "$USER_PROMPT" ]; then
    exit 0
fi

# Find the most recent scenario (highest numbered, or active status in metadata)
SCENARIO_ID=""
SCENARIO_DIR=""

# First try to find a scenario with status "active" or "in_progress"
for dir in $(ls -d scenarios/active/SCENARIO-* 2>/dev/null | sort -r); do
    if [ -f "$dir/metadata.json" ]; then
        STATUS=$(jq -r '.status // "active"' "$dir/metadata.json" 2>/dev/null)
        if [ "$STATUS" = "active" ] || [ "$STATUS" = "in_progress" ]; then
            SCENARIO_DIR="$dir"
            SCENARIO_ID=$(basename "$dir")
            break
        fi
    fi
done

# Fallback: use the highest numbered scenario (most recently created)
if [ -z "$SCENARIO_DIR" ]; then
    SCENARIO_DIR=$(ls -d scenarios/active/SCENARIO-* 2>/dev/null | sort -r | head -1)
    if [ -n "$SCENARIO_DIR" ] && [ -d "$SCENARIO_DIR" ]; then
        SCENARIO_ID=$(basename "$SCENARIO_DIR")
    fi
fi

# Skip if no active scenario
if [ -z "$SCENARIO_ID" ]; then
    exit 0
fi

# Source logging functions
source "$SCRIPT_DIR/../lib/log-dialog.sh" 2>/dev/null || {
    # Fallback: direct logging if lib not available
    LOG_FILE="$SCENARIO_DIR/moderator_dialog.jsonl"
    mkdir -p "$(dirname "$LOG_FILE")"

    # Log basic entry
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"timestamp\":\"$TIMESTAMP\",\"scenario_id\":\"$SCENARIO_ID\",\"type\":\"user_message\",\"content\":$(echo "$USER_PROMPT" | head -c 1000 | jq -Rs .)}" >> "$LOG_FILE"
    exit 0
}

# Detect interaction type based on user prompt patterns
INTERACTION_TYPE="user_input"

# User question detection
if echo "$USER_PROMPT" | grep -qiE "(\?|what|how|why|can you|could you|please explain|tell me)"; then
    INTERACTION_TYPE="user_question"
fi

# Validation/approval detection
if echo "$USER_PROMPT" | grep -qiE "^(yes|no|ok|okay|looks good|proceed|approve|lgtm|confirmed|good|great)"; then
    INTERACTION_TYPE="user_validation"
fi

# Correction/feedback detection
if echo "$USER_PROMPT" | grep -qiE "(actually|instead|change|correct|wrong|fix|update|but|however|not quite)"; then
    INTERACTION_TYPE="user_correction"
fi

# Log the interaction
USER_MSG_TRUNCATED=$(echo "$USER_PROMPT" | head -c 1000)

JSON=$(jq -n \
    --arg user_msg "$USER_MSG_TRUNCATED" \
    --arg itype "$INTERACTION_TYPE" \
    '{
        user_message: {
            content: $user_msg,
            message_type: $itype
        },
        outcome: {
            interaction_captured: true
        }
    }')

log_dialog "$SCENARIO_ID" "$INTERACTION_TYPE" "$JSON" 2>/dev/null || true

# Phase 0a guardrails (internal baseline + materials review)
phase_0_guardrails() {
    local scenario_dir="scenarios/active/$SCENARIO_ID"
    local materials_index="$scenario_dir/phase_0_discovery/materials_index.md"
    local worldview_model="$scenario_dir/worldview_model.md"
    local internal_baseline="$scenario_dir/phase_0_discovery/internal_baseline.md"
    local context_packet="$scenario_dir/phase_0_discovery/context_packet.md"
    local company_file="$scenario_dir/company.md"
    local warnings=""

    if [ -f "$materials_index" ] && [ -f "$company_file" ]; then
        if ! grep -qi "Materials Reviewed" "$company_file"; then
            warnings="${warnings}- Materials review not logged in company.md.\n"
        fi
    fi

    if [ ! -f "$worldview_model" ]; then
        warnings="${warnings}- Phase 0 worldview model missing (mandatory).\n"
    fi

    if [ -f "$company_file" ] && [ ! -f "$internal_baseline" ]; then
        warnings="${warnings}- Phase 0a internal baseline missing (mandatory).\n"
    fi

    if [ -f "$company_file" ]; then
        if [ ! -f "$context_packet" ]; then
            warnings="${warnings}- Phase 0b context enrichment packet missing (pp -r search).\n"
        elif grep -q "\\[gap\\]" "$context_packet"; then
            warnings="${warnings}- Phase 0b context enrichment packet not completed (pp -r search).\n"
        fi
    fi

    if [ -n "$warnings" ]; then
        echo ""
        echo "⚠️  Phase 0 Gate Incomplete"
        printf "%b" "$warnings"
        echo "Complete Phase 0 before moving to external analysis."
        echo ""
    fi
}

phase_0_guardrails

# Run quality gate check (separate from dialog logging)
# This checks if any phase synthesis files were recently created/updated
"$SCRIPT_DIR/quality-gate.sh" 2>/dev/null

exit 0
