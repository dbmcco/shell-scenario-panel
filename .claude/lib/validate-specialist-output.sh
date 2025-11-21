#!/bin/bash
# Validates specialist output files after invocation

set -e

# Source the file paths registry
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/file-paths.sh"

# Usage: validate_specialist_output SCENARIO_ID PHASE ROUND SPECIALIST
validate_specialist_output() {
    local SCENARIO_ID=$1
    local PHASE=$2
    local ROUND=$3
    local SPECIALIST=$4

    echo "🔍 Validating output for ${SPECIALIST} (Phase: ${PHASE}, Round: ${ROUND})"

    # Get expected file paths
    local EXPECTED_PATHS=$(get_specialist_paths "$SCENARIO_ID" "$PHASE" "$ROUND" "$SPECIALIST")

    if [ $? -ne 0 ]; then
        echo "❌ ERROR: Could not determine expected paths"
        return 1
    fi

    local VALIDATION_PASSED=true
    local MISSING_FILES=()
    local UNDERSIZED_FILES=()

    # Check each expected file
    while IFS= read -r filepath; do
        if [ -z "$filepath" ]; then
            continue
        fi

        if [ ! -f "$filepath" ]; then
            MISSING_FILES+=("$filepath")
            VALIDATION_PASSED=false
            continue
        fi

        # Check file size (minimum 100 words ≈ 500 characters)
        local filesize=$(wc -c < "$filepath" | tr -d ' ')
        if [ "$filesize" -lt 500 ]; then
            UNDERSIZED_FILES+=("$filepath (${filesize} bytes)")
            VALIDATION_PASSED=false
        fi

    done <<< "$EXPECTED_PATHS"

    # Report results
    if [ "$VALIDATION_PASSED" = true ]; then
        echo "✅ Validation PASSED for ${SPECIALIST}"
        return 0
    else
        echo "❌ Validation FAILED for ${SPECIALIST}"

        if [ ${#MISSING_FILES[@]} -gt 0 ]; then
            echo ""
            echo "Missing files:"
            for file in "${MISSING_FILES[@]}"; do
                echo "  - $file"
            done
        fi

        if [ ${#UNDERSIZED_FILES[@]} -gt 0 ]; then
            echo ""
            echo "Undersized files (< 500 bytes):"
            for file in "${UNDERSIZED_FILES[@]}"; do
                echo "  - $file"
            done
        fi

        echo ""
        echo "EXPECTED FILES:"
        echo "$EXPECTED_PATHS"

        return 1
    fi
}

# If called directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -ne 4 ]; then
        echo "Usage: $0 SCENARIO_ID PHASE ROUND SPECIALIST"
        echo ""
        echo "Examples:"
        echo "  $0 SCENARIO-2025-001 phase_2 1 economist"
        echo "  $0 SCENARIO-2025-001 uncertainties 2 futurist"
        exit 1
    fi

    validate_specialist_output "$1" "$2" "$3" "$4"
fi

# Export for sourcing
export -f validate_specialist_output
