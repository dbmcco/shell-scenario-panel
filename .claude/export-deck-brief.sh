#!/bin/bash
# Export Shell Scenario Panel outputs as a deck-ready brief
#
# Usage:
#   .claude/export-deck-brief.sh <scenario-id> [output-path]
#
# Examples:
#   .claude/export-deck-brief.sh SCENARIO-2025-001
#   .claude/export-deck-brief.sh SCENARIO-2025-001 ~/Desktop/scenario-brief.md
#   .claude/export-deck-brief.sh SCENARIO-2025-001 ../keynote-slides-skill/decks/futures/resources/materials/

set -e

SCENARIO_ID="${1:-}"
OUTPUT_PATH="${2:-}"

if [ -z "$SCENARIO_ID" ]; then
  echo "Usage: .claude/export-deck-brief.sh <scenario-id> [output-path]"
  echo ""
  echo "Available scenarios:"
  ls -1 scenarios/active/ 2>/dev/null || echo "  (none in active/)"
  exit 1
fi

# Check both active and archived
if [ -d "scenarios/active/${SCENARIO_ID}" ]; then
  SCENARIO_DIR="scenarios/active/${SCENARIO_ID}"
elif [ -d "scenarios/archived/${SCENARIO_ID}" ]; then
  SCENARIO_DIR="scenarios/archived/${SCENARIO_ID}"
elif [ -d "scenarios/${SCENARIO_ID}" ]; then
  SCENARIO_DIR="scenarios/${SCENARIO_ID}"
else
  echo "Error: Scenario not found: $SCENARIO_ID"
  exit 1
fi

# Default output path
if [ -z "$OUTPUT_PATH" ]; then
  OUTPUT_PATH="${SCENARIO_DIR}/deck-brief.md"
fi

# If output path is a directory, append filename
if [ -d "$OUTPUT_PATH" ]; then
  OUTPUT_PATH="${OUTPUT_PATH}/scenario-brief-${SCENARIO_ID}.md"
fi

echo "Exporting deck brief from: $SCENARIO_DIR"
echo "Output: $OUTPUT_PATH"

# Helper to include file if it exists
include_file() {
  local file="$1"
  local header="$2"
  if [ -f "$file" ]; then
    echo ""
    echo "---"
    echo ""
    echo "## $header"
    echo ""
    cat "$file"
  fi
}

# Helper to include file content without adding header
include_raw() {
  local file="$1"
  if [ -f "$file" ]; then
    echo ""
    echo "---"
    echo ""
    cat "$file"
  fi
}

# Build the consolidated brief
{
  echo "# Scenario Planning Brief: ${SCENARIO_ID}"
  echo ""
  echo "_Exported: $(date -u +"%Y-%m-%dT%H:%M:%SZ")_"
  echo ""
  echo "Use this brief as input materials for keynote-slides deck creation."
  echo "Copy to: \`decks/<deck-id>/resources/materials/scenario-brief.md\`"

  # Focal question (the key framing)
  include_file "${SCENARIO_DIR}/focal_question.md" "Focal Question"

  # Predetermined elements (what's locked in)
  include_file "${SCENARIO_DIR}/predetermined_elements.md" "Predetermined Elements"

  # Critical uncertainties (the scenario axes)
  include_file "${SCENARIO_DIR}/critical_uncertainties.md" "Critical Uncertainties"

  # Scenarios section
  echo ""
  echo "---"
  echo ""
  echo "## Scenarios"
  echo ""
  echo "Four plausible futures based on the critical uncertainties:"
  echo ""

  for scenario_file in "${SCENARIO_DIR}/scenarios/"scenario_*.md; do
    if [ -f "$scenario_file" ]; then
      # Extract scenario name from filename
      scenario_name=$(basename "$scenario_file" .md | sed 's/scenario_[0-9]*_//' | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
      echo ""
      echo "### ${scenario_name}"
      echo ""
      cat "$scenario_file"
    fi
  done

  # Early warning signals
  include_file "${SCENARIO_DIR}/early_warning_signals.md" "Early Warning Signals"

  # Strategy analysis (testing strategies across scenarios)
  include_file "${SCENARIO_DIR}/strategy_analysis.md" "Strategy Analysis"

  # Worldview integration
  include_file "${SCENARIO_DIR}/worldview_integration.md" "Worldview Integration"

  # Include key specialist insights (condensed)
  if [ -d "${SCENARIO_DIR}/conversations" ]; then
    echo ""
    echo "---"
    echo ""
    echo "## Key Specialist Insights"
    echo ""

    # Get unique specialist names from transcripts
    for transcript in "${SCENARIO_DIR}/conversations/"*_transcript.md; do
      if [ -f "$transcript" ]; then
        specialist_name=$(basename "$transcript" _transcript.md | sed 's/_uncertainties//' | sed 's/_predetermined//' | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
        echo ""
        echo "### ${specialist_name}"
        echo ""
        # Include first 40 lines to keep it concise
        head -40 "$transcript"
        line_count=$(wc -l < "$transcript")
        if [ "$line_count" -gt 40 ]; then
          echo ""
          echo "_[...truncated, see full transcript for details]_"
        fi
      fi
    done
  fi

} > "$OUTPUT_PATH"

echo ""
echo "Done! Brief exported to: $OUTPUT_PATH"
echo ""
echo "Next steps:"
echo "  1. Copy to keynote-slides materials:"
echo "     cp '$OUTPUT_PATH' ../keynote-slides-skill/decks/<deck-id>/resources/materials/"
echo ""
echo "  2. Run narrative build:"
echo "     cd ../keynote-slides-skill"
echo "     node scripts/ingest-resources.js decks/<deck-id>"
