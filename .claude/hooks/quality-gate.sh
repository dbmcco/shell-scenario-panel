#!/bin/bash

# Quality Gate Hook - Automatically enforces quality standards
# Triggers when phase synthesis documents are created/updated
# Blocks progression if quality standards not met

echo "🔍 Quality Gate - Checking for phase completion..."

# Find active scenario
SCENARIO_ID=""
SCENARIO_DIR=""
for dir in scenarios/active/SCENARIO-*; do
    if [ -d "$dir" ]; then
        SCENARIO_ID=$(basename "$dir")
        SCENARIO_DIR="$dir"
        break
    fi
done

# Skip if no active scenario
if [ -z "$SCENARIO_ID" ]; then
    exit 0
fi

# Source quality gate detection functions
SCRIPT_DIR="$(dirname "$0")"

# Function to check if file was recently modified (within last 2 minutes)
is_recently_modified() {
    local file=$1
    if [ ! -f "$file" ]; then
        return 1
    fi

    # Get file modification time (seconds since epoch)
    local file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
    local now=$(date +%s)
    local diff=$((now - file_time))

    # Consider recent if modified within last 120 seconds
    [ $diff -lt 120 ]
}

# Function to check if quality gate already passed for this checkpoint
quality_gate_already_passed() {
    local checkpoint=$1
    local audit_file="${SCENARIO_DIR}/conversations/quality_analyst_${checkpoint}.md"

    if [ ! -f "$audit_file" ]; then
        return 1  # No audit exists
    fi

    # Check if audit contains PASS determination
    if grep -q "PASS" "$audit_file" 2>/dev/null; then
        # Check if audit is more recent than synthesis file
        local synthesis_file=$2
        if [ -f "$synthesis_file" ]; then
            local audit_time=$(stat -f %m "$audit_file" 2>/dev/null || stat -c %Y "$audit_file" 2>/dev/null)
            local synthesis_time=$(stat -f %m "$synthesis_file" 2>/dev/null || stat -c %Y "$synthesis_file" 2>/dev/null)

            # If audit is newer than synthesis, consider it passed
            [ $audit_time -gt $synthesis_time ]
        else
            return 0  # Synthesis doesn't exist, assume passed
        fi
    else
        return 1  # Audit doesn't show PASS
    fi
}

# Function to trigger quality gate
trigger_quality_gate() {
    local checkpoint=$1
    local synthesis_file=$2

    echo ""
    echo "⚠️  QUALITY GATE REQUIRED: $checkpoint"
    echo ""
    echo "Phase synthesis detected: $(basename "$synthesis_file")"
    echo ""
    echo "📋 MODERATOR ACTION REQUIRED:"
    echo ""
    echo "Run quality gate analysis:"
    echo ""
    echo "Task(\"quality_analyst\", \"SCENARIO: $SCENARIO_ID"
    echo "CHECKPOINT: $checkpoint"
    echo ""
    echo "QUALITY AUDIT REQUEST:"
    echo "Evaluate intellectual integrity and quality regression."
    echo ""
    echo "FILES TO REVIEW:"
    echo "- Specialist transcripts in conversations/"
    echo "- Synthesis: $(basename "$synthesis_file")"
    echo ""
    echo "TRANSCRIPT PATH: scenarios/active/$SCENARIO_ID/conversations/quality_analyst_${checkpoint}.md"
    echo ""
    echo "Provide pass/fail determination with specific evidence.\")"
    echo ""
    echo "⛔ CANNOT PROCEED to next phase until quality gate PASSES"
    echo ""
}

# Check for Phase 2 completion (Predetermined Elements)
PHASE2_FILE="${SCENARIO_DIR}/predetermined_elements.md"
if is_recently_modified "$PHASE2_FILE"; then
    if ! quality_gate_already_passed "phase_2" "$PHASE2_FILE"; then
        trigger_quality_gate "phase_2" "$PHASE2_FILE"
        exit 0
    else
        echo "✅ Phase 2 quality gate already passed"
    fi
fi

# Check for Phase 3 completion (Critical Uncertainties)
PHASE3_FILE="${SCENARIO_DIR}/critical_uncertainties.md"
if is_recently_modified "$PHASE3_FILE"; then
    if ! quality_gate_already_passed "phase_3" "$PHASE3_FILE"; then
        trigger_quality_gate "phase_3" "$PHASE3_FILE"
        exit 0
    else
        echo "✅ Phase 3 quality gate already passed"
    fi
fi

# Check for Phase 4 completion (Scenarios created)
SCENARIOS_DIR="${SCENARIO_DIR}/scenarios"
if [ -d "$SCENARIOS_DIR" ]; then
    # Count scenario files
    SCENARIO_COUNT=$(find "$SCENARIOS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

    if [ "$SCENARIO_COUNT" -ge 3 ]; then
        # Check if any scenario file was recently modified
        RECENT_SCENARIO=$(find "$SCENARIOS_DIR" -name "*.md" -type f -mmin -2 2>/dev/null | head -1)

        if [ -n "$RECENT_SCENARIO" ]; then
            if ! quality_gate_already_passed "phase_4" "$RECENT_SCENARIO"; then
                trigger_quality_gate "phase_4" "$SCENARIOS_DIR"
                exit 0
            else
                echo "✅ Phase 4 quality gate already passed"
            fi
        fi
    fi
fi

# Check for Executive Summary (Final quality gate)
EXEC_SUMMARY="${SCENARIO_DIR}/executive_summary.md"
if is_recently_modified "$EXEC_SUMMARY"; then
    if ! quality_gate_already_passed "executive_summary" "$EXEC_SUMMARY"; then
        trigger_quality_gate "executive_summary" "$EXEC_SUMMARY"
        exit 0
    else
        echo "✅ Executive summary quality gate already passed"
    fi
fi

# No quality gates triggered
exit 0
