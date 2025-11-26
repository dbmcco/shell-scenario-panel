#!/bin/bash
# File Path Registry - Defines expected file locations for all phases

# Usage: get_specialist_paths SCENARIO_ID PHASE ROUND SPECIALIST
# Returns: Expected file paths for validation

get_specialist_paths() {
    local SCENARIO_ID=$1
    local PHASE=$2
    local ROUND=$3
    local SPECIALIST=$4

    local BASE="scenarios/active/${SCENARIO_ID}"

    # Special case: quality_analyst uses checkpoint naming
    if [ "$SPECIALIST" = "quality_analyst" ]; then
        # ROUND parameter contains checkpoint name (phase_2, phase_3, phase_4, executive_summary)
        echo "${BASE}/conversations/quality_analyst_${ROUND}.md"
        return 0
    fi

    case "$PHASE" in
        "phase_0_discovery")
            # Phase 0 discovery transcripts
            echo "${BASE}/phase_0_discovery/research/${SPECIALIST}_discovery_round${ROUND}.md"
            ;;

        "predetermined"|"phase_2")
            # Phase 2: Predetermined Elements
            echo "${BASE}/conversations/${SPECIALIST}_round${ROUND}_full.md"
            echo "${BASE}/conversations/${SPECIALIST}_round${ROUND}_summary.md"
            ;;

        "uncertainties"|"phase_3")
            # Phase 3: Critical Uncertainties
            echo "${BASE}/conversations/${SPECIALIST}_round${ROUND}_full.md"
            echo "${BASE}/conversations/${SPECIALIST}_round${ROUND}_summary.md"
            ;;

        "scenarios"|"phase_4")
            # Phase 4: Scenario Development
            if [ "$ROUND" = "3" ]; then
                # Round 3 only creates final, no summary
                echo "${BASE}/conversations/${SPECIALIST}_round${ROUND}_final.md"
            else
                echo "${BASE}/conversations/${SPECIALIST}_round${ROUND}_full.md"
                echo "${BASE}/conversations/${SPECIALIST}_round${ROUND}_summary.md"
            fi
            ;;

        "signals"|"phase_5")
            # Phase 5: Early Warning Signals
            echo "${BASE}/conversations/${SPECIALIST}_signals.md"
            ;;

        "strategy"|"phase_6")
            # Phase 6: Strategy Testing
            echo "${BASE}/conversations/${SPECIALIST}_strategy.md"
            ;;

        *)
            echo "ERROR: Unknown phase: $PHASE" >&2
            return 1
            ;;
    esac
}

# Usage: get_phase_outputs SCENARIO_ID PHASE
# Returns: Expected phase output files (not specialist transcripts)

get_phase_outputs() {
    local SCENARIO_ID=$1
    local PHASE=$2

    local BASE="scenarios/active/${SCENARIO_ID}"

    case "$PHASE" in
        "phase_0_discovery")
            echo "${BASE}/company.md"
            echo "${BASE}/phase_0_discovery/scenario_suggestions.md"
            ;;

        "phase_1"|"focal")
            echo "${BASE}/focal_question.md"
            ;;

        "phase_2"|"predetermined")
            echo "${BASE}/predetermined_elements.md"
            ;;

        "phase_3"|"uncertainties")
            echo "${BASE}/critical_uncertainties.md"
            ;;

        "phase_4"|"scenarios")
            # Multiple scenario files - check directory has at least 3 files
            echo "${BASE}/scenarios/"
            ;;

        "phase_6"|"strategy")
            echo "${BASE}/strategy_analysis.md"
            ;;

        *)
            echo "ERROR: Unknown phase: $PHASE" >&2
            return 1
            ;;
    esac
}

# Export functions
export -f get_specialist_paths
export -f get_phase_outputs
