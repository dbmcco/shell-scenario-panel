ABOUTME: Codex CLI instructions for Shell Scenario Panel.
ABOUTME: Enforces session bootstrap and resources-first intake.

# Codex CLI Instructions (Shell Scenario Panel)

## Required Startup

Before any scenario work, run:
```bash
.codex/session-start.sh
```

To resume an existing scenario:
```bash
.codex/session-start.sh --scenario SCENARIO-YYYY-NNN
```

This script initializes a scenario (if needed), indexes `resources/`, and prints the active `SCENARIO_ID`.

## Workflow

- Use `SCENARIO_ID` for all file paths.
- Follow `prompts/moderator.md` for Phase 0 elicitation and discovery.
- Do not bypass phase gates or file validation steps.
- Review `phase_0_discovery/materials_index.md` with the user before interviewing; re-run intake if materials change.
- Complete worldview elicitation (`worldview_model.md`) and internal baseline (`phase_0_discovery/internal_baseline.md`) before external analysis.

## Subagent Invocation (Codex)

When prompts reference the Task tool, run specialists via `codex-subagent` with the generated prompt.

Example:
```bash
PROMPT="$(
  .claude/lib/generate-specialist-prompt.sh "$SCENARIO_ID" phase_2 1 economist "Your question"
)"
printf "%s" "$PROMPT" | codex-subagent start \
  --role researcher \
  --permissions workspace-write \
  --label "economist-phase-2" \
  --prompt -

codex-subagent wait --labels "economist-phase-2" --follow-last
```

## Exports (Optional)

If HTML/TypeScript exports are generated, preview locally with:
```bash
.claude/lib/serve-exports.sh SCENARIO-YYYY-NNN
```
