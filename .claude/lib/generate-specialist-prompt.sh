#!/bin/bash
# Generates specialist invocation with explicit file paths

set -e

# Source the file paths registry
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/file-paths.sh"

# Usage: generate_specialist_prompt SCENARIO_ID PHASE ROUND SPECIALIST [QUESTION]
generate_specialist_prompt() {
    local SCENARIO_ID=$1
    local PHASE=$2
    local ROUND=$3
    local SPECIALIST=$4
    local QUESTION=$5

    # Get expected file paths
    local EXPECTED_PATHS=$(get_specialist_paths "$SCENARIO_ID" "$PHASE" "$ROUND" "$SPECIALIST")

    if [ $? -ne 0 ]; then
        echo "ERROR: Could not determine expected paths" >&2
        return 1
    fi

    # Generate prompt with explicit paths
    cat <<EOF
SCENARIO: ${SCENARIO_ID}
PHASE: ${PHASE}
ROUND: ${ROUND}

${QUESTION}

CRITICAL FILE REQUIREMENTS:
You MUST create the following files. Validation will check for these exact paths:

EOF

    # List each expected file with instructions
    local file_num=1
    while IFS= read -r filepath; do
        if [ -z "$filepath" ]; then
            continue
        fi

        local filename=$(basename "$filepath")

        if [[ "$filename" == *"_full.md" ]]; then
            cat <<EOF
${file_num}. FULL ANALYSIS: ${filepath}
   - Minimum 500 words of substantive analysis
   - Complete reasoning and evidence
   - Citations where applicable

EOF
        elif [[ "$filename" == *"_summary.md" ]]; then
            cat <<EOF
${file_num}. SUMMARY: ${filepath}
   - 3-5 key points (bullets)
   - 100-word executive summary
   - Maximum 200 words total

EOF
        elif [[ "$filename" == *"_final.md" ]]; then
            cat <<EOF
${file_num}. FINAL ANALYSIS: ${filepath}
   - Complete final integration
   - Minimum 500 words
   - No summary needed

EOF
        else
            cat <<EOF
${file_num}. OUTPUT: ${filepath}
   - Minimum 500 words
   - Follow format guidelines for this phase

EOF
        fi

        file_num=$((file_num + 1))
    done <<< "$EXPECTED_PATHS"

    cat <<EOF

VALIDATION:
After you complete your analysis, these files will be automatically validated.
If any file is missing or undersized, you will be asked to recreate it.

DO NOT use alternative paths or filenames. Use EXACTLY the paths listed above.
EOF
}

# If called directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ $# -lt 4 ]; then
        echo "Usage: $0 SCENARIO_ID PHASE ROUND SPECIALIST [QUESTION]"
        echo ""
        echo "Examples:"
        echo "  $0 SCENARIO-2025-001 phase_2 1 economist \"What debt is locked in?\""
        exit 1
    fi

    generate_specialist_prompt "$@"
fi

# Export for sourcing
export -f generate_specialist_prompt
