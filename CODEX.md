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

To create a new scenario explicitly:
```bash
.codex/session-start.sh --new
```

To open a scenario for monitoring:
```bash
.codex/session-start.sh --monitor SCENARIO-YYYY-NNN
```

This script prints the active `SCENARIO_ID` and `SESSION_MODE`.

## Workflow

- Use `SCENARIO_ID` for all file paths.
- Follow `prompts/moderator.md` for Phase 0 elicitation and discovery.
- For monitoring runs, use `.claude/monitoring-run.sh "$SCENARIO_ID" --type scheduled|ad_hoc`.
- Do not bypass phase gates or file validation steps.
- Check `resources/` for files and ask the user whether to scan and incorporate them before running intake.
- Review `phase_0_discovery/materials_index.md` with the user before interviewing; re-run intake if materials change.
- Complete worldview elicitation (`worldview_model.md`), context enrichment (`phase_0_discovery/context_packet.md`), and internal baseline (`phase_0_discovery/internal_baseline.md`) before external analysis.
- For web search, use `pp -r --no-interactive "query" --output json` only.

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
