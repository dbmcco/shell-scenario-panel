# Metadata Structure Documentation

This document explains the structure of `metadata.json` files in scenario directories.

## Overview

Each scenario has a `metadata.json` file that tracks:
- Scenario identification and status
- Current phase and progress
- Specialist consultations
- Phase-specific tracking data
- Validation status

## Standard Fields (All Phases)

```json
{
  "scenario_id": "SCENARIO-YYYY-NNN",
  "created_at": "ISO 8601 timestamp",
  "status": "active" | "archived",
  "current_phase": 0-6,
  "phase": "phase_name",
  "focal_question": "string",
  "time_horizon": "string",
  "scope": "string",
  "consultations": [
    {
      "specialist": "specialist_id",
      "timestamp": "ISO 8601 timestamp",
      "phase": "phase_name",
      "transcript_path": "conversations/specialist_transcript.md",
      "validated": true | false
    }
  ],
  "validation_status": "pending" | "validated" | "revision_needed",
  "next_action": "string describing next step",
  "notes": "optional notes"
}
```

## Phase-Specific Fields

### Phase 0: Discovery

Phase 0 uses a **nested structure** (different from other phases) to track iterative discovery rounds:

```json
{
  "current_phase": 0,
  "phase": "phase_0_discovery",
  "phase_0": {
    "discovery_rounds": 2,
    "specialists_consulted": ["economist", "geopolitician", "ecologist", ...],
    "convergence_reached": true,
    "user_confirmed": true,
    "scenario_suggestions_generated": true
  }
}
```

**Why nested?** Phase 0 is unique in that:
- It involves multiple rounds of the same specialists
- It tracks convergence across rounds
- It generates scenario suggestions (not present in other phases)
- The discovery process is iterative rather than linear

This separate structure makes it easier to:
- Count discovery rounds independently
- Track which specialists participated across all rounds
- Determine when convergence is reached
- Manage the transition to Phase 1

### Phase 1: Focal Question

```json
{
  "current_phase": 1,
  "phase": "understanding",
  "focal_question": "The specific question being explored",
  "time_horizon": "10 years",
  "scope": "US auto parts manufacturing industry"
}
```

### Phase 2: Predetermined Elements

```json
{
  "current_phase": 2,
  "phase": "predetermined",
  "predetermined_elements_identified": true
}
```

### Phase 3: Critical Uncertainties

```json
{
  "current_phase": 3,
  "phase": "uncertainties",
  "critical_uncertainties_identified": true,
  "scenario_axes": {
    "axis_1": {
      "name": "EV Transition Speed",
      "low_state": "Gradual",
      "high_state": "Accelerated"
    },
    "axis_2": {
      "name": "Regulatory Environment",
      "low_state": "Permissive",
      "high_state": "Restrictive"
    }
  }
}
```

### Phase 4: Scenario Development

```json
{
  "current_phase": 4,
  "phase": "scenario_development",
  "scenarios_developed": 4,
  "target_scenario_count": 4,
  "scenario_names": [
    "Scenario 1: Name",
    "Scenario 2: Name",
    "Scenario 3: Name",
    "Scenario 4: Name"
  ]
}
```

### Phase 5: Early Warning Signals

```json
{
  "current_phase": 5,
  "phase": "early_warning",
  "early_warning_signals_defined": true
}
```

### Phase 6: Strategy Testing

```json
{
  "current_phase": 6,
  "phase": "strategy_testing",
  "robust_strategies_identified": true,
  "strategies_tested": 3
}
```

## Consultations Array

The `consultations` array tracks ALL specialist consultations across all phases (except Phase 0 discovery, which uses the nested structure):

```json
"consultations": [
  {
    "specialist": "economist",
    "timestamp": "2025-11-21T10:30:00Z",
    "phase": "predetermined",
    "transcript_path": "conversations/economist_transcript.md",
    "validated": true
  },
  {
    "specialist": "geopolitician",
    "timestamp": "2025-11-21T14:15:00Z",
    "phase": "predetermined",
    "transcript_path": "conversations/geopolitician_transcript.md",
    "validated": true
  }
]
```

**Fields:**
- `specialist`: ID from config.json specialists roster
- `timestamp`: ISO 8601 format
- `phase`: Which phase this consultation occurred in
- `transcript_path`: Relative path from scenario directory
- `validated`: Whether moderator validated the transcript

## Validation

Use `.claude/validate-scenario.sh SCENARIO-YYYY-NNN` to verify:
- All consultations have corresponding transcripts
- Transcripts meet minimum word count (100 words)
- Metadata structure is valid JSON
- Required fields are present
- No orphaned transcripts (transcripts without consultation records)

## Best Practices

1. **Update immediately** after specialist consultations
2. **Use ISO 8601 timestamps** for all dates
3. **Track validation status** to enable recovery from interruptions
4. **Document next_action** to make resumption clear
5. **Keep consultations array complete** for audit trail
6. **Validate regularly** using the validation script

## Example: Complete Phase 2 Metadata

```json
{
  "scenario_id": "SCENARIO-2025-001",
  "created_at": "2025-11-21T09:00:00Z",
  "status": "active",
  "current_phase": 2,
  "phase": "predetermined",
  "focal_question": "How should Acme Auto Parts position itself for 2025-2035?",
  "time_horizon": "10 years",
  "scope": "US auto parts manufacturing, OEM suppliers",
  "consultations": [
    {
      "specialist": "economist",
      "timestamp": "2025-11-21T10:30:00Z",
      "phase": "predetermined",
      "transcript_path": "conversations/economist_transcript.md",
      "validated": true
    },
    {
      "specialist": "geopolitician",
      "timestamp": "2025-11-21T14:15:00Z",
      "phase": "predetermined",
      "transcript_path": "conversations/geopolitician_transcript.md",
      "validated": true
    }
  ],
  "validation_status": "validated",
  "predetermined_elements_identified": true,
  "next_action": "Move to Phase 3: Critical Uncertainties",
  "notes": "Strong consensus on predetermined elements. Both specialists aligned on debt constraints and supply chain restructuring."
}
```
