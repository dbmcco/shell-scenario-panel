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

## Exports (Optional)

If HTML/TypeScript exports are generated, preview locally with:
```bash
.claude/lib/serve-exports.sh SCENARIO-YYYY-NNN
```
