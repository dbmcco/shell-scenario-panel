#!/bin/bash
# Resolve the impact kernel plus any named overlay packs into a deduplicated specialist roster.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_FILE="${ROOT_DIR}/.claude/config.json"

FORMAT="lines"
LIST_ONLY=false
declare -a overlays=()

usage() {
    cat <<EOF
Usage:
  $0 [--format lines|csv|json] [overlay ...]
  $0 --list-overlays

Examples:
  $0
  $0 household_personal
  $0 commercial_positioning
  $0 household_personal commercial_positioning --format json
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --format)
            FORMAT="${2:-}"
            shift 2
            ;;
        --list-overlays)
            LIST_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            overlays+=("$1")
            shift
            ;;
    esac
done

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Missing config file: $CONFIG_FILE" >&2
    exit 1
fi

if [[ "$LIST_ONLY" == true ]]; then
    jq -r '
      .impact_panels.overlays
      | to_entries[]
      | "\(.key)\t\(.value.description)\t\(.value.specialists | join(","))"
    ' "$CONFIG_FILE"
    exit 0
fi

declare -a selected=()

contains_specialist() {
    local needle="$1"
    local item
    if [ "${#selected[@]}" -eq 0 ]; then
        return 1
    fi
    for item in "${selected[@]}"; do
        if [[ "$item" == "$needle" ]]; then
            return 0
        fi
    done
    return 1
}

add_specialist() {
    local specialist="$1"
    if ! contains_specialist "$specialist"; then
        selected+=("$specialist")
    fi
}

while IFS= read -r specialist; do
    [[ -n "$specialist" ]] && add_specialist "$specialist"
done < <(jq -r '.impact_panels.kernel[]' "$CONFIG_FILE")

for overlay in "${overlays[@]}"; do
    if ! jq -e --arg overlay "$overlay" '.impact_panels.overlays[$overlay]' "$CONFIG_FILE" >/dev/null; then
        echo "ERROR: Unknown overlay '$overlay'" >&2
        echo "Available overlays:" >&2
        jq -r '.impact_panels.overlays | keys[]' "$CONFIG_FILE" >&2
        exit 1
    fi

    while IFS= read -r specialist; do
        [[ -n "$specialist" ]] && add_specialist "$specialist"
    done < <(jq -r --arg overlay "$overlay" '.impact_panels.overlays[$overlay].specialists[]' "$CONFIG_FILE")
done

case "$FORMAT" in
    lines)
        printf '%s\n' "${selected[@]}"
        ;;
    csv)
        (
            IFS=,
            printf '%s\n' "${selected[*]}"
        )
        ;;
    json)
        printf '%s\n' "${selected[@]}" | jq -R . | jq -s .
        ;;
    *)
        echo "ERROR: Unsupported format '$FORMAT'" >&2
        usage >&2
        exit 1
        ;;
esac
