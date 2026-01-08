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
    mkdir -p "$SCENARIO_DIR/phase_0_discovery/research"
    mkdir -p "$SCENARIO_DIR/exports"
    mkdir -p "$SCENARIO_DIR/artifacts"
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
  "worldview_captured": false,
  "focal_question": "",
  "time_horizon": "",
  "scope": "",
  "phase": "worldview_elicitation",
  "consultations": [],
  "last_specialist": null,
  "next_action": "begin_worldview_elicitation",
  "validation_status": "pending_user_input",
  "predetermined_elements_identified": false,
  "critical_uncertainties_identified": false,
  "scenarios_developed": 0,
  "target_scenario_count": 4,
  "worldview_integration_complete": false,
  "notes": ""
}
EOF
echo "✅ Metadata initialized"

# Copy templates
cp templates/focal_question.md "$SCENARIO_DIR/"
cp templates/worldview_model.md "$SCENARIO_DIR/"
cp templates/worldview_integration.md "$SCENARIO_DIR/"
echo "✅ Templates copied (focal_question, worldview_model, worldview_integration)"

# Create scenario_context.md from template
cp templates/scenario_context_template.md "$SCENARIO_DIR/scenario_context.md"

# Add initial timestamp
cat >> "$SCENARIO_DIR/scenario_context.md" << CONTEXT_EOF

## Scenario Initialized ($(date -u +"%Y-%m-%d %H:%M"))

Initial context captured in company.md.
User feedback will be added below as scenario planning progresses.

---
CONTEXT_EOF
echo "✅ Scenario context file initialized"

echo ""
echo "🎉 Scenario $SCENARIO_ID initialized successfully!"
echo ""
echo "📁 Location: $SCENARIO_DIR"
echo "📋 Status: Active"
echo "🔄 Phase: Phase 0 - Worldview Elicitation"
echo "➡️  Next Action: Dr. Wells will use worldview-elicitor to understand your mental model"
echo ""
echo "To begin, set environment variable:"
echo "export SCENARIO_ID=$SCENARIO_ID"
echo ""

exit 0
