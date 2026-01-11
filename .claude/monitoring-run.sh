#!/bin/bash
# Shell Scenario Panel - Monitoring Run Script
# Creates a monitoring run log and updates metadata

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCENARIO_ID=""
RUN_TYPE="scheduled"

while [ $# -gt 0 ]; do
  case "$1" in
    --scenario)
      SCENARIO_ID="${2:-}"
      shift 2
      ;;
    --type)
      RUN_TYPE="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--scenario SCENARIO-YYYY-NNN] [--type scheduled|ad_hoc]" >&2
      exit 0
      ;;
    *)
      if [ -z "$SCENARIO_ID" ]; then
        SCENARIO_ID="$1"
        shift
      else
        echo "Unknown argument: $1" >&2
        exit 1
      fi
      ;;
  esac
done

if [ -z "$SCENARIO_ID" ]; then
  echo "Usage: $0 [--scenario SCENARIO-YYYY-NNN] [--type scheduled|ad_hoc]" >&2
  exit 1
fi

SCENARIO_DIR="$ROOT/scenarios/active/$SCENARIO_ID"
if [ ! -d "$SCENARIO_DIR" ]; then
  echo "Scenario not found: $SCENARIO_DIR" >&2
  exit 1
fi

MONITOR_DIR="$SCENARIO_DIR/monitoring"
RUN_DIR="$MONITOR_DIR/runs"
mkdir -p "$RUN_DIR"

if [ ! -f "$MONITOR_DIR/monitoring_plan.md" ]; then
  cp "$ROOT/templates/monitoring_plan.md" "$MONITOR_DIR/monitoring_plan.md"
fi
if [ ! -f "$MONITOR_DIR/monitoring_log.md" ]; then
  cp "$ROOT/templates/monitoring_log.md" "$MONITOR_DIR/monitoring_log.md"
fi

RUN_SLUG=$(date -u +"%Y-%m-%d_%H%M")
RUN_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
RUN_FILE="$RUN_DIR/monitoring_run_${RUN_SLUG}.md"

if [ -f "$RUN_FILE" ]; then
  echo "Monitoring run already exists: $RUN_FILE" >&2
  exit 1
fi

cat > "$RUN_FILE" <<EOF
# Monitoring Run - $RUN_SLUG

## Run Context
- Scenario ID: $SCENARIO_ID
- Run Type: $RUN_TYPE
- Timestamp (UTC): $RUN_TS
- Analyst:

## Inputs Reviewed
- Sources:
- Signals reviewed:

## Signal Updates (by scenario)
### Scenario 1: [Name]
- Signal:
- Direction:
- Notes:

### Scenario 2: [Name]
- Signal:
- Direction:
- Notes:

### Scenario 3: [Name]
- Signal:
- Direction:
- Notes:

### Scenario 4: [Name]
- Signal:
- Direction:
- Notes:

## Scenario Drift Assessment
- Most supported scenario:
- Contradicting signals:
- Confidence:

## Recommended Updates
- Scenario document updates:
- Strategy adjustments:
- Next check:

## Decisions (Model-Mediated)
- Update required?:
- Rationale:
EOF

LOG_FILE="$MONITOR_DIR/monitoring_log.md"
RUN_REL="monitoring/runs/$(basename "$RUN_FILE")"
printf "| %s | %s | %s | %s | %s |\n" \
  "$(date -u +"%Y-%m-%d")" \
  "$RUN_TYPE" \
  "pending" \
  "pending" \
  "$RUN_REL" >> "$LOG_FILE"

METADATA_FILE="$SCENARIO_DIR/metadata.json"
if [ -f "$METADATA_FILE" ]; then
  tmp_file="$(mktemp)"
  jq --arg ts "$RUN_TS" '
    .monitoring = (.monitoring // {}) |
    .monitoring.status = "active" |
    .monitoring.last_run_at = $ts |
    .monitoring.run_count = ((.monitoring.run_count // 0) + 1)
  ' "$METADATA_FILE" > "$tmp_file"
  mv "$tmp_file" "$METADATA_FILE"
fi

echo "✅ Monitoring run created: $RUN_FILE"
echo "✅ Log appended: $LOG_FILE"
echo "✅ Metadata updated: $METADATA_FILE"
