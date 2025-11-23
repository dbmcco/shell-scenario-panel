# Moderator-User Dialog Recording System

## Purpose

Capture moderator-user interactions for future Reinforcement Learning training:
- Fine-tune moderator facilitation strategies
- Identify successful interaction patterns
- Learn from user feedback and validation signals
- Improve checkpoint timing and question formulation

## Design Principles

1. **Minimal intrusion** - Recording should not disrupt workflow
2. **Structured format** - Easy to parse for ML training
3. **Rich context** - Include phase, specialist consultations, decisions
4. **Quality signals** - Capture user satisfaction, validation, iteration requests
5. **Privacy-aware** - User controls what's recorded, can redact later

---

## File Structure

**Location:** `scenarios/active/SCENARIO-YYYY-NNN/moderator_dialog.jsonl`

**Format:** JSON Lines (one JSON object per line for streaming/append)

Each interaction logged as separate JSON object.

---

## Dialog Entry Schema

```json
{
  "timestamp": "2025-11-21T15:30:45Z",
  "scenario_id": "SCENARIO-2025-001",
  "phase": "phase_2",
  "round": 1,
  "interaction_type": "checkpoint",
  "context": {
    "specialists_consulted": ["economist", "geopolitician", "ecologist"],
    "files_created": [
      "conversations/economist_round1_full.md",
      "conversations/economist_round1_summary.md"
    ],
    "synthesis_length_words": 342,
    "checkpoint_number": 1
  },
  "moderator_message": {
    "content": "Round 1 complete. Here's what specialists found regarding predetermined elements:\n\n[synthesis content]\n\nQuick checkpoint:\n- Any corrections to data they're working with?\n- Any new context this triggered?\n- Major factors they're missing?\n\n(Say 'looks good' if nothing significant)",
    "message_type": "checkpoint_prompt",
    "prompt_structure": {
      "synthesis_provided": true,
      "questions_asked": 3,
      "tone": "collaborative"
    }
  },
  "user_response": {
    "content": "Actually, our revenue is $900M not $850M, and we're in acquisition talks with CompetitorX for $200M",
    "response_type": "correction_and_new_context",
    "signals": {
      "provided_correction": true,
      "correction_magnitude": "moderate",
      "new_strategic_context": true,
      "expressed_satisfaction": false,
      "requested_clarification": false
    }
  },
  "moderator_action": {
    "action_taken": "evaluate_and_query",
    "significance_evaluation": "major",
    "proposed_action": "re-round",
    "reasoning": "Revenue correction >10% and new M&A context significantly changes specialist analysis assumptions"
  },
  "user_decision": {
    "decision": "proceed_without_reround",
    "reasoning": "Incorporate in next phase, not critical for predetermined elements",
    "decision_time_seconds": 12
  },
  "outcome": {
    "checkpoint_successful": true,
    "feedback_captured": true,
    "scenario_context_updated": true,
    "iteration_triggered": false,
    "user_validated": true
  },
  "quality_signals": {
    "user_engagement_level": "high",
    "feedback_specificity": "high",
    "decision_confidence": "high",
    "moderator_effectiveness": "good"
  }
}
```

---

## Interaction Types

Track different kinds of moderator-user interactions:

1. **checkpoint** - After specialist round, presenting synthesis
2. **validation_request** - Asking user to validate phase output
3. **clarification** - Moderator asking for clarification
4. **user_question** - User asking moderator a question
5. **specialist_selection** - Deciding which specialists to consult
6. **phase_transition** - Moving between phases
7. **feedback** - General user feedback on process
8. **error_recovery** - Handling mistakes or misunderstandings

---

## Quality Signals for RL

### User Response Signals

```json
"signals": {
  "provided_correction": true/false,
  "correction_magnitude": "minor|moderate|major",
  "new_strategic_context": true/false,
  "expressed_satisfaction": true/false,
  "expressed_confusion": true/false,
  "requested_clarification": true/false,
  "validated_output": true/false,
  "engagement_indicators": {
    "response_length_words": 45,
    "specificity_level": "high|medium|low",
    "detail_provided": true/false
  }
}
```

### Moderator Effectiveness Signals

```json
"quality_signals": {
  "user_engagement_level": "high|medium|low",
  "feedback_specificity": "high|medium|low",
  "decision_confidence": "high|medium|low",
  "moderator_effectiveness": "excellent|good|fair|poor",
  "checkpoint_timing": "too_early|appropriate|too_late",
  "question_quality": "clear|somewhat_clear|confusing"
}
```

### Outcome Signals (RL Rewards)

```json
"outcome": {
  "checkpoint_successful": true,
  "feedback_captured": true,
  "user_validated": true,
  "iteration_triggered": false,
  "phase_completed": true,
  "user_satisfaction_score": 0.85
}
```

---

## Logging Mechanism

### When to Log

Log interactions at:
1. **Every checkpoint** - Most critical for RL
2. **Every validation request** - User approval/rejection signals
3. **User questions** - Indicates confusion or need for clarification
4. **Phase transitions** - Completion signals
5. **Errors/recoveries** - Learning from mistakes

### What NOT to Log

- Internal moderator reasoning (unless it affects decisions)
- Specialist transcripts (already captured separately)
- Trivial acknowledgments ("ok", "got it")
- System/technical errors unrelated to facilitation

---

## Implementation

### 1. Dialog Logger Function

```bash
# .claude/lib/log-dialog.sh

log_dialog() {
    local SCENARIO_ID=$1
    local INTERACTION_TYPE=$2
    local DIALOG_JSON=$3  # Full JSON object as string

    local LOG_FILE="scenarios/active/${SCENARIO_ID}/moderator_dialog.jsonl"

    # Append JSON line
    echo "$DIALOG_JSON" >> "$LOG_FILE"
}
```

### 2. Moderator Logging Protocol

Add to moderator.md:

```markdown
## DIALOG RECORDING (FOR RL TRAINING)

After key interactions, log the exchange:

1. **After checkpoints:**
   - Your synthesis and questions
   - User's response (corrections, context, validation)
   - Your significance evaluation
   - User's decision (iterate or proceed)
   - Outcome (feedback captured, validation status)

2. **After validation requests:**
   - What you presented for validation
   - User's response (approved, requested changes, questions)
   - Any modifications needed

3. **After user questions:**
   - User's question
   - Your response
   - Whether it resolved the confusion

Use TodoWrite to track: "[completed] Logged checkpoint interaction"
```

### 3. Quality Signal Extraction

Can be automated or moderator-assessed:

**Automated signals:**
- Response length (word count)
- Timestamp differences (response time)
- Correction detection (keywords: "actually", "correction", "wrong")
- New context detection (keywords: "also", "additionally", "forgot to mention")

**Moderator-assessed signals:**
- Significance evaluation (already doing this)
- User engagement level
- Effectiveness self-assessment

---

## Privacy & Control

### User Controls

1. **Opt-out available** - User can disable recording
2. **Redaction support** - Can redact sensitive info post-hoc
3. **Review access** - User can review what's been logged
4. **Company-specific data** - Handled carefully, can be anonymized

### Anonymization

For public RL training datasets:
- Replace company names with placeholders
- Redact revenue/financial specifics
- Keep interaction patterns and quality signals
- Preserve phase structure and specialist consultations

---

## RL Training Use Cases

### 1. Checkpoint Timing Optimization

**Question:** When should moderator present checkpoints?

**Signals:**
- checkpoint_timing: "too_early|appropriate|too_late"
- user_feedback_quality at checkpoint
- iteration_triggered rate by timing

**Training:** Learn optimal checkpoint timing based on phase, round, specialist count

### 2. Question Formulation

**Question:** What checkpoint questions get best user engagement?

**Signals:**
- user_response.engagement_indicators
- feedback_specificity
- correction_magnitude

**Training:** Learn which question structures elicit useful feedback

### 3. Significance Evaluation

**Question:** How accurately does moderator assess feedback significance?

**Signals:**
- moderator_action.significance_evaluation
- user_decision.decision (did user agree with evaluation?)
- outcome.iteration_triggered vs. moderator_action.proposed_action

**Training:** Improve moderator's ability to assess when iteration is needed

### 4. Synthesis Quality

**Question:** What synthesis characteristics lead to user validation?

**Signals:**
- synthesis_length_words
- user_response.validated_output
- user_response.requested_clarification

**Training:** Learn optimal synthesis length, structure, detail level

---

## Metadata Tracking

Also log scenario-level metadata for RL context:

```json
{
  "scenario_id": "SCENARIO-2025-001",
  "scenario_metadata": {
    "total_phases": 6,
    "total_checkpoints": 12,
    "total_specialist_consultations": 49,
    "total_iterations_triggered": 3,
    "user_satisfaction_overall": 0.9,
    "completion_time_hours": 4.5,
    "scenario_successful": true
  }
}
```

Append to moderator_dialog.jsonl at scenario completion.

---

## Next Steps

1. Implement log-dialog.sh function
2. Update moderator.md with logging protocol
3. Create dialog entry templates for each interaction type
4. Test with fresh scenario
5. Design RL training pipeline (future work)

---

## Example Dialog Sequence

```jsonl
{"timestamp":"2025-11-21T14:00:00Z","interaction_type":"checkpoint","phase":"phase_2","moderator_message":"Round 1 complete...","user_response":"Revenue is actually $900M...","outcome":{"user_validated":true}}
{"timestamp":"2025-11-21T14:15:00Z","interaction_type":"validation_request","phase":"phase_2","moderator_message":"Here's predetermined_elements.md...","user_response":"Looks good, proceed","outcome":{"phase_completed":true}}
{"timestamp":"2025-11-21T14:30:00Z","interaction_type":"checkpoint","phase":"phase_3","moderator_message":"Round 1 complete...","user_response":"This is great, no additions","outcome":{"user_validated":true}}
```

Clean, parseable, ready for ML training.
