#!/bin/bash

# Dialog Recording Hook
# Automatically captures moderator-user interactions from conversation history
# Triggers after each user message

# Source logging functions
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/../lib/log-dialog.sh" 2>/dev/null || {
    exit 0  # Silently skip if logging not available
}

# Find active scenario
SCENARIO_ID=""
for scenario_dir in scenarios/active/SCENARIO-*; do
    if [ -d "$scenario_dir" ]; then
        SCENARIO_ID=$(basename "$scenario_dir")
        break
    fi
done

# Skip if no active scenario
if [ -z "$SCENARIO_ID" ]; then
    exit 0
fi

# Find current session's conversation file
PROJECT_PATH=$(pwd | sed 's|/|-|g' | sed 's|^-||')
CONVERSATION_DIR="$HOME/.claude/projects/$PROJECT_PATH"

if [ ! -d "$CONVERSATION_DIR" ]; then
    exit 0
fi

# Get most recent non-agent conversation file
CURRENT_SESSION=$(ls -t "$CONVERSATION_DIR"/*.jsonl 2>/dev/null | grep -v "agent-" | head -1)

if [ -z "$CURRENT_SESSION" ] || [ ! -f "$CURRENT_SESSION" ]; then
    exit 0
fi

# Get last 10 messages (5 exchanges typically)
RECENT_MESSAGES=$(tail -20 "$CURRENT_SESSION" | jq -s '[.[] | select(.type == "user" or .type == "assistant")] | .[-10:]')

# Analyze for interaction patterns
# Look for checkpoint patterns: moderator presents synthesis, user responds
# Look for validation patterns: moderator asks for approval, user validates
# Look for question patterns: user asks clarification

# Extract last user message
LAST_USER_MSG=$(echo "$RECENT_MESSAGES" | jq -r '.[-1] | select(.type == "user") | .message.content // empty')
LAST_ASSISTANT_MSG=$(echo "$RECENT_MESSAGES" | jq -r '.[-2] | select(.type == "assistant") | .message.content // empty')

if [ -z "$LAST_USER_MSG" ] || [ -z "$LAST_ASSISTANT_MSG" ]; then
    exit 0
fi

# Detect interaction type based on patterns
INTERACTION_TYPE=""

# Checkpoint detection: moderator synthesis + user feedback
if echo "$LAST_ASSISTANT_MSG" | grep -qiE "(checkpoint|round.*complete|synthesis|quick check|any corrections|looks good)"; then
    if echo "$LAST_USER_MSG" | grep -qviE "^(looks good|ok|yes|no|proceed)$"; then
        INTERACTION_TYPE="checkpoint"
    fi
fi

# Validation detection: moderator requests validation
if echo "$LAST_ASSISTANT_MSG" | grep -qiE "(validate|approval|does this.*look|ready to|shall we proceed)"; then
    INTERACTION_TYPE="validation_request"
fi

# User question detection: user asks for clarification
if echo "$LAST_USER_MSG" | grep -qE "(\?|what|how|why|can you|could you|please explain)"; then
    INTERACTION_TYPE="user_question"
fi

# Only log if we detected a loggable interaction
if [ -n "$INTERACTION_TYPE" ]; then
    # Truncate messages for logging (first 500 chars)
    USER_MSG_TRUNCATED=$(echo "$LAST_USER_MSG" | head -c 500)
    ASSISTANT_MSG_TRUNCATED=$(echo "$LAST_ASSISTANT_MSG" | head -c 500)

    # Create JSON log entry
    JSON=$(jq -n \
        --arg mod_msg "$ASSISTANT_MSG_TRUNCATED" \
        --arg user_msg "$USER_MSG_TRUNCATED" \
        --arg itype "$INTERACTION_TYPE" \
        '{
            moderator_message: {
                content: $mod_msg,
                message_type: $itype
            },
            user_response: {
                content: $user_msg,
                response_type: "feedback"
            },
            outcome: {
                interaction_captured: true
            }
        }')

    # Log to dialog file
    log_dialog "$SCENARIO_ID" "$INTERACTION_TYPE" "$JSON" 2>/dev/null
fi

exit 0
