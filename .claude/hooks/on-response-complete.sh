#!/bin/bash

# On Response Complete Hook
# Checks for panel completion and triggers export/artifact generation
# Runs after each Claude response (Stop event)

set -e

SCRIPT_DIR="$(dirname "$0")"
LIB_DIR="$SCRIPT_DIR/../lib"

# Find the most recent scenario (highest numbered, or active status in metadata)
SCENARIO_DIR=""
SCENARIO_ID=""

# First try to find a scenario with status "active" or "in_progress"
for dir in $(ls -d scenarios/active/SCENARIO-* 2>/dev/null | sort -r); do
    if [ -f "$dir/metadata.json" ]; then
        STATUS=$(jq -r '.status // "active"' "$dir/metadata.json" 2>/dev/null)
        if [ "$STATUS" = "active" ] || [ "$STATUS" = "in_progress" ]; then
            SCENARIO_DIR="$dir"
            SCENARIO_ID=$(basename "$dir")
            break
        fi
    fi
done

# Fallback: use the highest numbered scenario (most recently created)
if [ -z "$SCENARIO_DIR" ]; then
    SCENARIO_DIR=$(ls -d scenarios/active/SCENARIO-* 2>/dev/null | sort -r | head -1)
    if [ -n "$SCENARIO_DIR" ] && [ -d "$SCENARIO_DIR" ]; then
        SCENARIO_ID=$(basename "$SCENARIO_DIR")
    fi
fi

# Exit silently if no active scenario
if [ -z "$SCENARIO_DIR" ]; then
    exit 0
fi

# Check if panel is complete (executive_summary.md exists and strategy_analysis.md exists)
EXEC_SUMMARY="$SCENARIO_DIR/executive_summary.md"
STRATEGY="$SCENARIO_DIR/strategy_analysis.md"
METADATA="$SCENARIO_DIR/metadata.json"

# Only proceed if both completion indicators exist
if [ ! -f "$EXEC_SUMMARY" ] || [ ! -f "$STRATEGY" ]; then
    exit 0
fi

# Check if we've already processed completion for this scenario
COMPLETION_MARKER="$SCENARIO_DIR/.completion_processed"
if [ -f "$COMPLETION_MARKER" ]; then
    exit 0
fi

# Check metadata status - only run on first completion
if [ -f "$METADATA" ]; then
    STATUS=$(jq -r '.status // "active"' "$METADATA" 2>/dev/null)
    if [ "$STATUS" = "complete" ]; then
        # Already marked complete, check if exports exist
        if [ -d "$SCENARIO_DIR/exports" ] && [ "$(ls -A "$SCENARIO_DIR/exports" 2>/dev/null)" ]; then
            touch "$COMPLETION_MARKER"
            exit 0
        fi
    fi
fi

echo ""
echo "=============================================="
echo "  PANEL COMPLETION DETECTED"
echo "=============================================="
echo ""
echo "Scenario: $SCENARIO_ID"
echo ""

# Generate exports
echo "Generating exports..."
mkdir -p "$SCENARIO_DIR/exports"
mkdir -p "$SCENARIO_DIR/artifacts"

# Export 1: Combined analysis markdown
COMBINED_EXPORT="$SCENARIO_DIR/exports/complete_analysis.md"
{
    echo "# $SCENARIO_ID - Complete Analysis"
    echo ""
    echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    echo "---"
    echo ""

    # Executive Summary
    if [ -f "$EXEC_SUMMARY" ]; then
        echo "# Executive Summary"
        echo ""
        cat "$EXEC_SUMMARY"
        echo ""
        echo "---"
        echo ""
    fi

    # Strategy Analysis
    if [ -f "$STRATEGY" ]; then
        echo "# Strategy Analysis"
        echo ""
        cat "$STRATEGY"
        echo ""
        echo "---"
        echo ""
    fi

    # Worldview Integration
    WORLDVIEW_INT="$SCENARIO_DIR/worldview_integration.md"
    if [ -f "$WORLDVIEW_INT" ]; then
        echo "# Worldview Integration"
        echo ""
        cat "$WORLDVIEW_INT"
        echo ""
        echo "---"
        echo ""
    fi

    # Options/Scenarios
    for option in "$SCENARIO_DIR/scenarios/"*.md; do
        if [ -f "$option" ]; then
            OPTION_NAME=$(basename "$option" .md)
            echo "# Option: $OPTION_NAME"
            echo ""
            cat "$option"
            echo ""
            echo "---"
            echo ""
        fi
    done

} > "$COMBINED_EXPORT"

echo "  Created: exports/complete_analysis.md"

# Export 2: HTML report
HTML_EXPORT="$SCENARIO_DIR/exports/report.html"
{
    cat << 'HTMLHEAD'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Analysis Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 900px; margin: 0 auto; padding: 2rem; line-height: 1.6; }
        h1 { color: #1a1a2e; border-bottom: 2px solid #4a4e69; padding-bottom: 0.5rem; }
        h2 { color: #4a4e69; margin-top: 2rem; }
        h3 { color: #6c757d; }
        .meta { color: #6c757d; font-size: 0.9rem; margin-bottom: 2rem; }
        .section { background: #f8f9fa; padding: 1.5rem; border-radius: 8px; margin: 1rem 0; }
        hr { border: none; border-top: 1px solid #dee2e6; margin: 2rem 0; }
        ul { padding-left: 1.5rem; }
        li { margin: 0.5rem 0; }
        blockquote { border-left: 4px solid #4a4e69; margin: 1rem 0; padding-left: 1rem; color: #495057; }
    </style>
</head>
<body>
HTMLHEAD

    echo "<h1>Panel Analysis Report</h1>"
    echo "<p class=\"meta\">Scenario: $SCENARIO_ID | Generated: $(date)</p>"

    # Convert markdown sections to HTML (simplified)
    if [ -f "$EXEC_SUMMARY" ]; then
        echo "<div class=\"section\">"
        echo "<h2>Executive Summary</h2>"
        # Simple markdown to HTML conversion
        sed 's/^# /<h1>/; s/^## /<h2>/; s/^### /<h3>/; s/^- /<li>/; s/^$/<br>/' "$EXEC_SUMMARY"
        echo "</div>"
    fi

    if [ -f "$STRATEGY" ]; then
        echo "<div class=\"section\">"
        echo "<h2>Strategy Analysis</h2>"
        sed 's/^# /<h1>/; s/^## /<h2>/; s/^### /<h3>/; s/^- /<li>/; s/^$/<br>/' "$STRATEGY"
        echo "</div>"
    fi

    echo "</body></html>"
} > "$HTML_EXPORT"

echo "  Created: exports/report.html"

# Export 3: JSON summary for programmatic access
JSON_EXPORT="$SCENARIO_DIR/exports/summary.json"
{
    jq -n \
        --arg scenario_id "$SCENARIO_ID" \
        --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        --arg exec_summary "$(cat "$EXEC_SUMMARY" 2>/dev/null | head -c 2000)" \
        --arg strategy "$(cat "$STRATEGY" 2>/dev/null | head -c 2000)" \
        '{
            scenario_id: $scenario_id,
            generated_at: $generated_at,
            status: "complete",
            exports: {
                complete_analysis: "exports/complete_analysis.md",
                html_report: "exports/report.html",
                json_summary: "exports/summary.json"
            },
            content_preview: {
                executive_summary: $exec_summary,
                strategy_analysis: $strategy
            }
        }'
} > "$JSON_EXPORT"

echo "  Created: exports/summary.json"

# Create artifacts bundle
echo ""
echo "Creating artifacts bundle..."
ARTIFACT_BUNDLE="$SCENARIO_DIR/artifacts/bundle_$(date +%Y%m%d_%H%M%S).tar.gz"

# Bundle key files
(cd "$SCENARIO_DIR" && tar -czf "artifacts/bundle_$(date +%Y%m%d_%H%M%S).tar.gz" \
    executive_summary.md \
    strategy_analysis.md \
    worldview_model.md \
    worldview_integration.md \
    predetermined_elements.md \
    critical_uncertainties.md \
    scenarios/*.md \
    exports/*.md \
    exports/*.html \
    exports/*.json \
    metadata.json \
    2>/dev/null || true)

echo "  Created: artifacts/bundle_*.tar.gz"

# Log completion to dialog (if logging is available)
if [ -f "$LIB_DIR/log-dialog.sh" ]; then
    source "$LIB_DIR/log-dialog.sh" 2>/dev/null

    # Count files for stats
    TRANSCRIPT_COUNT=$(find "$SCENARIO_DIR/panel_transcripts" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    log_scenario_completion "$SCENARIO_ID" "0" "$TRANSCRIPT_COUNT" "0" "complete" 2>/dev/null || true
fi

# Update metadata to mark complete
if [ -f "$METADATA" ]; then
    jq '.status = "complete" | .completed_at = now | .exports_generated = true' "$METADATA" > "$METADATA.tmp" && mv "$METADATA.tmp" "$METADATA"
fi

# Mark completion as processed
touch "$COMPLETION_MARKER"

echo ""
echo "=============================================="
echo "  EXPORTS COMPLETE"
echo "=============================================="
echo ""
echo "Files generated:"
echo "  - exports/complete_analysis.md"
echo "  - exports/report.html"
echo "  - exports/summary.json"
echo "  - artifacts/bundle_*.tar.gz"
echo ""
echo "Serve exports with:"
echo "  .claude/lib/serve-exports.sh $SCENARIO_ID"
echo ""

exit 0
