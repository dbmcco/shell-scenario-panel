#!/bin/bash

# Shell Scenario Panel Post-Completion Hook
# Auto-exports deck brief when panel completes (worldview_integration.md created)

SCRIPT_DIR="$(dirname "$0")"
PANEL_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Find active scenario
SCENARIO_ID=""
SCENARIO_DIR=""
for dir in "$PANEL_ROOT"/scenarios/active/SCENARIO-*; do
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

# Check if worldview_integration.md was recently created (within 2 minutes)
INTEGRATION_FILE="$SCENARIO_DIR/worldview_integration.md"
if [ ! -f "$INTEGRATION_FILE" ]; then
    exit 0
fi

# Get file modification time
FILE_TIME=$(stat -f %m "$INTEGRATION_FILE" 2>/dev/null || stat -c %Y "$INTEGRATION_FILE" 2>/dev/null)
NOW=$(date +%s)
DIFF=$((NOW - FILE_TIME))

# Only trigger if recently modified (within 120 seconds)
if [ $DIFF -gt 120 ]; then
    exit 0
fi

# Check if we already exported (prevent duplicate runs)
BRIEF_FILE="$SCENARIO_DIR/deck-brief.md"
if [ -f "$BRIEF_FILE" ]; then
    BRIEF_TIME=$(stat -f %m "$BRIEF_FILE" 2>/dev/null || stat -c %Y "$BRIEF_FILE" 2>/dev/null)
    # If brief is newer than integration, skip
    if [ "$BRIEF_TIME" -ge "$FILE_TIME" ]; then
        exit 0
    fi
fi

echo ""
echo "🔮 Scenario Panel Complete - Generating deck brief..."
echo ""

# Run the export
cd "$PANEL_ROOT"
if .claude/export-deck-brief.sh "$SCENARIO_ID" 2>/dev/null; then
    echo ""
    echo "✅ Deck brief exported: $SCENARIO_DIR/deck-brief.md"
    echo ""
    echo "📋 Next: Copy to keynote-slides deck materials:"
    echo "   cp '$SCENARIO_DIR/deck-brief.md' ../keynote-slides-skill/decks/<deck-id>/resources/materials/"
    echo ""
fi

exit 0
