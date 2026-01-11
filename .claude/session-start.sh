#!/bin/bash
# ABOUTME: Claude session bootstrapper for Shell Scenario Panel.
# ABOUTME: Enforces model-mediated selection of scenario vs monitoring.

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCENARIO_ID=""
SESSION_MODE="planning"

if [ "${1:-}" = "--scenario" ]; then
  SCENARIO_ID="${2:-}"
  if [ -z "$SCENARIO_ID" ]; then
    echo "Usage: $0 [--scenario SCENARIO-YYYY-NNN]" >&2
    exit 1
  fi
  if [ ! -d "$ROOT/scenarios/active/$SCENARIO_ID" ]; then
    echo "Scenario not found: scenarios/active/$SCENARIO_ID" >&2
    exit 1
  fi
elif [ "${1:-}" = "--monitor" ]; then
  SESSION_MODE="monitoring"
  SCENARIO_ID="${2:-}"
  if [ -z "$SCENARIO_ID" ]; then
    echo "Usage: $0 --monitor SCENARIO-YYYY-NNN" >&2
    exit 1
  fi
  if [ ! -d "$ROOT/scenarios/active/$SCENARIO_ID" ]; then
    echo "Scenario not found: scenarios/active/$SCENARIO_ID" >&2
    exit 1
  fi
elif [ "${1:-}" = "--new" ]; then
  "$ROOT/.claude/scenario-init.sh"
  SCENARIO_DIR=$(ls -td "$ROOT"/scenarios/active/SCENARIO-* 2>/dev/null | head -n1 || true)
  if [ -z "$SCENARIO_DIR" ]; then
    echo "No active scenario directory found." >&2
    exit 1
  fi
  SCENARIO_ID="$(basename "$SCENARIO_DIR")"
else
  echo "Model-mediated selection required."
  echo "Decide whether to resume an existing scenario or create a new one."
  echo "Do not rely on regex or heuristic triggers."
  echo ""
  "$ROOT/.claude/list-scenarios.sh"
  echo "To resume: $0 --scenario SCENARIO-YYYY-NNN"
  echo "To monitor: $0 --monitor SCENARIO-YYYY-NNN"
  echo "To create new: $0 --new"
  exit 0
fi

if [ "$SESSION_MODE" = "monitoring" ]; then
  echo "Monitoring mode enabled for $SCENARIO_ID."
  echo "Review monitoring plan/log before deciding on updates:"
  echo "- scenarios/active/$SCENARIO_ID/monitoring/monitoring_plan.md"
  echo "- scenarios/active/$SCENARIO_ID/monitoring/monitoring_log.md"
else
  RESOURCES_DIR="$ROOT/resources"
  RESOURCE_COUNT=0
  if [ -d "$RESOURCES_DIR" ]; then
    RESOURCE_COUNT=$(find "$RESOURCES_DIR" -type f \
      ! -name "README.md" \
      ! -name ".gitkeep" \
      ! -name ".DS_Store" | wc -l | tr -d ' ')
  fi

  MATERIALS_INDEX="$ROOT/scenarios/active/$SCENARIO_ID/phase_0_discovery/materials_index.md"
  if [ "$RESOURCE_COUNT" -gt 0 ]; then
    echo "Resources detected ($RESOURCE_COUNT files). Ask the user if they want to scan and incorporate them."
    echo "If yes, run: .claude/lib/resources-intake.sh \"$SCENARIO_ID\" and review materials_index.md."
    if [ -f "$MATERIALS_INDEX" ]; then
      echo "Materials index exists (review with user before ingesting): $MATERIALS_INDEX"
    fi
  else
    echo "No resources found; proceed with blind interview."
  fi
fi

echo "SCENARIO_ID=$SCENARIO_ID"
echo "SESSION_MODE=$SESSION_MODE"
echo "Next: follow prompts/moderator.md for Phase 0 elicitation and discovery."
