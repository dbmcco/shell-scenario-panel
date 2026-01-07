#!/bin/bash
# ABOUTME: Build a materials index from repo resources for Phase 0 intake.
# ABOUTME: Creates a lightweight preview file for the moderator to read first.

set -e

SCENARIO_ID=$1
if [ -z "$SCENARIO_ID" ]; then
    echo "Usage: $0 SCENARIO-YYYY-NNN" >&2
    exit 1
fi

SCENARIO_DIR="scenarios/active/${SCENARIO_ID}"
RESOURCES_DIR="resources"
OUTPUT_DIR="${SCENARIO_DIR}/phase_0_discovery"
OUTPUT_FILE="${OUTPUT_DIR}/materials_index.md"

if [ ! -d "$RESOURCES_DIR" ]; then
    echo "Resources directory not found: ${RESOURCES_DIR}"
    exit 0
fi

RESOURCE_FILES=$(find "$RESOURCES_DIR" -type f \
    ! -name "README.md" \
    ! -name ".gitkeep" \
    ! -name ".DS_Store")

if [ -z "$RESOURCE_FILES" ]; then
    echo "No resources found in ${RESOURCES_DIR}"
    exit 0
fi

mkdir -p "$OUTPUT_DIR"

{
    echo "# Materials Index"
    echo ""
    echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%SZ")"
    echo ""
    echo "This index lists available resources and includes light previews when possible."
    echo ""
} > "$OUTPUT_FILE"

while IFS= read -r file; do
    [ -z "$file" ] && continue

    filename=$(basename "$file")
    filesize=$(wc -c < "$file" | tr -d ' ')
    filetype=$(file -b "$file" 2>/dev/null || echo "unknown")

    {
        echo "## ${filename}"
        echo "- Path: ${file}"
        echo "- Size: ${filesize} bytes"
        echo "- Type: ${filetype}"
        echo ""
    } >> "$OUTPUT_FILE"

    case "$file" in
        *.md|*.txt|*.csv|*.tsv|*.json|*.yaml|*.yml)
            {
                echo "### Text Preview"
                echo '```'
                head -n 40 "$file"
                echo '```'
                echo ""
            } >> "$OUTPUT_FILE"
            ;;
        *.pdf)
            if command -v pdftotext >/dev/null 2>&1; then
                {
                    echo "### PDF Text Preview"
                    echo '```'
                    pdftotext "$file" - 2>/dev/null | head -n 40
                    echo '```'
                    echo ""
                } >> "$OUTPUT_FILE"
            else
                {
                    echo "### Notes"
                    echo "PDF preview not available (pdftotext missing)."
                    echo ""
                } >> "$OUTPUT_FILE"
            fi
            ;;
        *)
            {
                echo "### Notes"
                echo "No preview available for this file type."
                echo ""
            } >> "$OUTPUT_FILE"
            ;;
    esac
done <<< "$RESOURCE_FILES"

echo "Materials index created: ${OUTPUT_FILE}"
