#!/bin/bash

# Shell Scenario Panel - Scenario Initialization Script
# Creates new scenario directory with proper structure

set -e

echo "🎯 Shell Scenario Panel - Scenario Initialization"
echo ""

# Get current year
YEAR=$(date +%Y)

# Find next available scenario number
NEXT_NUM=1
while [ -d "scenarios/active/SCENARIO-$YEAR-$(printf '%03d' $NEXT_NUM)" ] || \
      [ -d "scenarios/archived/SCENARIO-$YEAR-$(printf '%03d' $NEXT_NUM)" ]; do
    NEXT_NUM=$((NEXT_NUM + 1))
done

SCENARIO_ID="SCENARIO-$YEAR-$(printf '%03d' $NEXT_NUM)"
SCENARIO_DIR="scenarios/active/$SCENARIO_ID"

echo "Creating scenario: $SCENARIO_ID"

# Check if scenario already exists and is complete
if [ -d "$SCENARIO_DIR" ]; then
    STATUS=$(jq -r '.status // "unknown"' "$SCENARIO_DIR/metadata.json" 2>/dev/null || echo "unknown")

    if [[ "$STATUS" == *"complete"* ]]; then
        echo "❌ Error: Cannot overwrite completed scenario $SCENARIO_ID"
        echo "   Use archive-scenario.sh first if you want to reuse this ID"
        exit 1
    fi

    echo "⚠️  Scenario $SCENARIO_ID already exists with status: $STATUS"
    read -p "Continue with existing scenario? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    # Create directory structure
    mkdir -p "$SCENARIO_DIR/conversations"
    mkdir -p "$SCENARIO_DIR/scenarios"
    mkdir -p "$SCENARIO_DIR/artifacts"
    mkdir -p "$SCENARIO_DIR/phase_0_discovery/research"
    echo "✅ Directory structure created"
fi

# Create metadata from template
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$SCENARIO_DIR/metadata.json" <<EOF
{
  "scenario_id": "$SCENARIO_ID",
  "created_at": "$TIMESTAMP",
  "status": "active",
  "current_phase": 0,
  "phase_0": {
    "discovery_rounds": 0,
    "specialists_consulted": [],
    "convergence_reached": false,
    "user_confirmed": false,
    "scenario_suggestions_generated": false
  },
  "focal_question": "",
  "time_horizon": "",
  "scope": "",
  "phase": "phase_0_discovery",
  "consultations": [],
  "last_specialist": null,
  "next_action": "begin_company_discovery",
  "validation_status": "pending_user_input",
  "predetermined_elements_identified": false,
  "critical_uncertainties_identified": false,
  "scenarios_developed": 0,
  "target_scenario_count": 4,
  "notes": ""
}
EOF
echo "✅ Metadata initialized"

# Copy templates
cp templates/focal_question.md "$SCENARIO_DIR/"
echo "✅ Focal question template copied"

echo ""
echo "🎉 Scenario $SCENARIO_ID initialized successfully!"
echo ""
echo "📁 Location: $SCENARIO_DIR"
echo "📋 Status: Active"
echo "🔄 Phase: Phase 0 - Company Discovery"
echo "➡️  Next Action: Dr. Wells will ask about company discovery or focal question"
echo ""
echo "To begin, set environment variable:"
echo "export SCENARIO_ID=$SCENARIO_ID"
echo ""

exit 0
