ABOUTME: CLI-friendly UI flow sketch for Shell Scenario Panel with elicitation.
ABOUTME: Documents sequence, artifacts, and reconciliation touchpoints.

# Shell Scenario Panel UI Flow (CLI)

## Flow Overview

```
Start Session
  -> Phase 0a: Elicitation Interview (internal baseline)
  -> Phase 0b: Company Discovery + specialist research (external context)
  -> Phase 1-5: External scenario build (existing workflow)
  -> Phase 6: Strategy testing
  -> Reconciliation: Mismatch Map + Decision Calibration
```

## Step Detail (CLI Screens)

### 1) Phase 0a: Elicitation Interview (Internal Baseline)
Purpose: Capture the user's base case, assumptions, and risk posture.

CLI layout:
```
PHASE 0a - Elicitation Interview
- Decision: [focal decision]
- Time horizon: [time horizon]
- Base case: [most likely future]
- Conditions required: [assumptions]
- Fragile assumptions: [top 2]
- Risk posture: [check size, loss tolerance]
- Disconfirmers: [what changes mind]
```

Artifacts:
- `scenarios/active/[SCENARIO-ID]/phase_0_discovery/internal_baseline.md`
- `scenarios/active/[SCENARIO-ID]/company.md` (basic context)
- `scenarios/active/[SCENARIO-ID]/phase_0_discovery/materials_index.md` (if resources exist)

### 2) Phase 0b: Company Discovery (External Context)
Purpose: Run specialist research and identify focal question options.

CLI layout:
```
PHASE 0b - Discovery Round N
- Specialist themes: [summary bullets]
- Follow-up questions: [2-4 items]
- User responses: [captured]
```

Artifacts:
- `scenarios/active/[SCENARIO-ID]/phase_0_discovery/research/*_discovery_roundN.md`
- `scenarios/active/[SCENARIO-ID]/phase_0_discovery/scenario_suggestions.md`

### 3) Phase 1-5: External Scenario Build
Purpose: Generate scenarios without anchoring to the internal baseline.

CLI layout:
```
PHASE 1-5 - External Scenarios
- Predetermined elements
- Critical uncertainties
- Scenario narratives
- Early warning signals
```

Artifacts:
- `predetermined_elements.md`
- `critical_uncertainties.md`
- `scenarios/scenario_*.md`
- `early_warning_signals.md`

### 4) Phase 6: Strategy Testing
Purpose: Evaluate strategies across external scenarios.

CLI layout:
```
PHASE 6 - Strategy Testing
- Robust strategies
- Adaptive strategies
- Scenario-specific risks
```

Artifact:
- `strategy_analysis.md`

### 5) Reconciliation: Mismatch Map + Decision Calibration
Purpose: Compare internal baseline to external scenarios and calibrate decisions.

CLI layout:
```
RECONCILIATION
Base case vs external scenarios:
- Assumption A: [user expects] -> [external finding]
- Assumption B: [user expects] -> [external finding]

Decision calibration:
- If risk posture = conservative: [recommended posture]
- If risk posture = aggressive: [recommended posture]
```

Artifacts:
- `strategy_analysis.md` (add "Mismatch Map" and "Decision Calibration" sections)
- `scenario_context.md` (record user reactions to mismatches)

## Notes

- Keep Phase 0a separate from external scenario generation to reduce anchoring bias.
- The reconciliation step is where the value shift happens: show the user how their internal model diverges from external drivers.
