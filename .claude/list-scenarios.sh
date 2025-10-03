#!/bin/bash

# Shell Scenario Panel - List Scenarios Script
# Displays all active and archived scenarios with status

echo "📊 Shell Scenario Panel - Scenario List"
echo ""

# List active scenarios
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ACTIVE SCENARIOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ACTIVE_COUNT=0
if [ -d "scenarios/active" ]; then
    for scenario_dir in scenarios/active/SCENARIO-*; do
        if [ -d "$scenario_dir" ]; then
            SCENARIO_ID=$(basename "$scenario_dir")
            METADATA="$scenario_dir/metadata.json"

            if [ -f "$METADATA" ]; then
                PHASE=$(jq -r '.phase // "unknown"' "$METADATA")
                STATUS=$(jq -r '.status // "active"' "$METADATA")
                CREATED=$(jq -r '.created_at // "unknown"' "$METADATA")
                FOCAL_Q=$(jq -r '.focal_question // ""' "$METADATA" | head -c 50)
                CONSULTATIONS=$(jq -r '.consultations | length' "$METADATA")
                NEXT_ACTION=$(jq -r '.next_action // "unknown"' "$METADATA")

                echo "📁 $SCENARIO_ID"
                echo "   Status: $STATUS | Phase: $PHASE"
                echo "   Created: $CREATED"
                if [ -n "$FOCAL_Q" ]; then
                    echo "   Question: $FOCAL_Q..."
                fi
                echo "   Consultations: $CONSULTATIONS"
                echo "   Next: $NEXT_ACTION"
                echo ""

                ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
            fi
        fi
    done
fi

if [ $ACTIVE_COUNT -eq 0 ]; then
    echo "No active scenarios found."
    echo ""
fi

# List archived scenarios
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ARCHIVED SCENARIOS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ARCHIVE_COUNT=0
if [ -d "scenarios/archived" ]; then
    for scenario_dir in scenarios/archived/SCENARIO-*; do
        if [ -d "$scenario_dir" ]; then
            SCENARIO_ID=$(basename "$scenario_dir")
            METADATA="$scenario_dir/metadata.json"

            if [ -f "$METADATA" ]; then
                STATUS=$(jq -r '.status // "archived"' "$METADATA")
                ARCHIVED_AT=$(jq -r '.archived_at // "unknown"' "$METADATA")
                FOCAL_Q=$(jq -r '.focal_question // ""' "$METADATA" | head -c 50)
                SCENARIO_COUNT=$(jq -r '.scenarios_developed // 0' "$METADATA")

                echo "📦 $SCENARIO_ID"
                echo "   Status: $STATUS"
                echo "   Archived: $ARCHIVED_AT"
                if [ -n "$FOCAL_Q" ]; then
                    echo "   Question: $FOCAL_Q..."
                fi
                echo "   Scenarios Developed: $SCENARIO_COUNT"
                echo ""

                ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))
            fi
        fi
    done
fi

if [ $ARCHIVE_COUNT -eq 0 ]; then
    echo "No archived scenarios found."
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $ACTIVE_COUNT active, $ARCHIVE_COUNT archived"
echo ""

exit 0
