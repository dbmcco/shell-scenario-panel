#!/bin/bash

# Shell Scenario Panel Post-Task Hook
# Runs after any Task tool invocation (specialist consultation)
# Keeps validation simple - detailed checks are moderator's responsibility

echo "📋 Shell Scenario Panel - Post-Task Check..."

# Only run checks if we're in an active scenario context
SCENARIO_FOUND=false
for scenario_dir in scenarios/active/SCENARIO-*; do
    if [ -d "$scenario_dir" ]; then
        SCENARIO_FOUND=true
        break
    fi
done

if [ "$SCENARIO_FOUND" = false ]; then
    echo "ℹ️  No active scenarios - skipping validation"
    exit 0
fi

# Check that conversations directory exists for transcript storage
if [ ! -d "scenarios/active/SCENARIO-"* ]; then
    echo "⚠️  Warning: No active scenario directories found"
    exit 0
fi

# General reminder about documentation requirements
echo "✅ Task completed"
echo ""
echo "📝 Moderator Responsibilities:"
echo "   - Verify specialist created transcript in conversations/"
echo "   - Check transcript contains >100 words of analysis"
echo "   - Update metadata.json with consultation record"
echo "   - Get user validation before next specialist"
echo ""

exit 0
