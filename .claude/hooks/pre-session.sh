#!/bin/bash

# Shell Scenario Panel Pre-Session Hook
# Displays project info at session start

echo "🎯 Shell Scenario Panel - Scenario Planning System"
echo ""

# Check for active scenarios
ACTIVE_COUNT=0
if [ -d "scenarios/active" ]; then
    ACTIVE_COUNT=$(find scenarios/active -maxdepth 1 -type d -name "SCENARIO-*" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ $ACTIVE_COUNT -eq 0 ]; then
    echo "📁 No active scenarios"
    echo ""
    echo "To begin:"
    echo "  1. Run: .claude/scenario-init.sh"
    echo "  2. Start conversation with Dr. Michelle Wells"
    echo ""
else
    echo "📁 Active Scenarios: $ACTIVE_COUNT"
    echo ""

    # Show latest scenario
    LATEST=$(ls -t scenarios/active/SCENARIO-* 2>/dev/null | head -1)
    if [ -n "$LATEST" ] && [ -f "$LATEST/metadata.json" ]; then
        SCENARIO_ID=$(basename "$LATEST")
        PHASE=$(jq -r '.phase // "unknown"' "$LATEST/metadata.json" 2>/dev/null)

        echo "Latest: $SCENARIO_ID"
        echo "Phase: $PHASE"
        echo ""
    fi

    echo "Use .claude/list-scenarios.sh to see all scenarios"
    echo ""
fi

# Display specialist roster
echo "👥 Available Specialists:"
echo ""
echo "  Domain Experts:"
echo "    • Elena (Ecologist) - Systems dynamics, feedback loops"
echo "    • Marcus (Geopolitician) - Power, resources, state interests"
echo "    • Aisha (Anthropologist) - Cultural shifts, values"
echo "    • Kenji (Futurist) - Technology capabilities, platform shifts"
echo "    • Sarah (Economist) - Debt dynamics, financial structures"
echo "    • Jamie (Contrarian) - Challenge assumptions, hidden risks"
echo ""
echo "  Research Specialist:"
echo "    • Anya (Researcher) - Multi-source analysis, gap-filling"
echo ""

echo "✅ Ready for scenario planning"
exit 0
