#!/bin/bash

# Shell Scenario Panel - Archive Scenario Script
# Moves completed scenario to archive directory

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 SCENARIO-YYYY-NNN"
    echo ""
    echo "Archives a completed scenario by moving it to scenarios/archived/"
    echo ""
    exit 1
fi

SCENARIO_ID=$1
SOURCE_DIR="scenarios/active/$SCENARIO_ID"
TARGET_DIR="scenarios/archived/$SCENARIO_ID"

echo "📦 Archiving scenario: $SCENARIO_ID"
echo ""

# Verify source exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Scenario $SCENARIO_ID not found in active scenarios"
    exit 1
fi

# Verify target doesn't exist
if [ -d "$TARGET_DIR" ]; then
    echo "❌ Error: Scenario $SCENARIO_ID already exists in archive"
    exit 1
fi

# Check metadata
METADATA="$SOURCE_DIR/metadata.json"
if [ ! -f "$METADATA" ]; then
    echo "❌ Error: Metadata not found for scenario $SCENARIO_ID"
    exit 1
fi

STATUS=$(jq -r '.status // "unknown"' "$METADATA")
PHASE=$(jq -r '.phase // "unknown"' "$METADATA")

echo "Current Status: $STATUS"
echo "Current Phase: $PHASE"
echo ""

# Confirm archival
read -p "Archive this scenario? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Archival cancelled."
    exit 0
fi

# Create archive directory if needed
mkdir -p scenarios/archived

# Update metadata with archive timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq ".status = \"archived\" | .archived_at = \"$TIMESTAMP\"" "$METADATA" > "$METADATA.tmp"
mv "$METADATA.tmp" "$METADATA"

# Move to archive
mv "$SOURCE_DIR" "$TARGET_DIR"

echo "✅ Scenario archived successfully"
echo "📁 Location: $TARGET_DIR"
echo ""

exit 0
