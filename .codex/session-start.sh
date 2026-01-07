#!/bin/bash
# ABOUTME: Codex session bootstrapper for Shell Scenario Panel.
# ABOUTME: Enforces scenario init and resources-first intake before proceeding.

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCENARIO_ID=""

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
else
  "$ROOT/.claude/scenario-init.sh"
  SCENARIO_DIR=$(ls -td "$ROOT"/scenarios/active/SCENARIO-* 2>/dev/null | head -n1 || true)
  if [ -z "$SCENARIO_DIR" ]; then
    echo "No active scenario directory found." >&2
    exit 1
  fi
  SCENARIO_ID="$(basename "$SCENARIO_DIR")"
fi

if [ -x "$ROOT/.claude/lib/resources-intake.sh" ]; then
  "$ROOT/.claude/lib/resources-intake.sh" "$SCENARIO_ID" || true
else
  echo "resources-intake.sh not found; skipping materials index."
fi

MATERIALS_INDEX="$ROOT/scenarios/active/$SCENARIO_ID/phase_0_discovery/materials_index.md"
if [ -f "$MATERIALS_INDEX" ]; then
  echo "Materials index ready: $MATERIALS_INDEX"
else
  echo "No materials index found; proceed with blind interview."
fi

echo "SCENARIO_ID=$SCENARIO_ID"
echo "Next: follow prompts/moderator.md for Phase 0 elicitation and discovery."
