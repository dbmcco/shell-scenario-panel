# User Feedback Checkpoints Design

## Design Date: 2025-11-21

## Problem Statement

As users exercise the scenario planning capability, they provide additional context through interaction with the moderator that would be valuable for specialists - but specialists have already completed their analysis based on initial context.

**Types of emerging context:**
- Corrections to initial data
- New strategic factors previously unmentioned
- Deeper understanding emerging through the process
- Reactions to specialist insights that trigger memories

**Current gap:** Moderator discusses this feedback with user, but it's unclear if/how it flows back to specialists for further evaluation.

**Timing:** Primarily emerges in Phases 2-3 when specialists probe predetermined elements and critical uncertainties.

## Design Goals

**Priorities:**
1. **Completeness:** User must feel "yes, they captured everything I was thinking"
2. **User time:** Minimize waiting time (more important than dollar cost of agent invocations)
3. **No endless loops:** Need circuit breakers to prevent infinite iteration

**Constraints:**
- Don't want constant back-and-forth with specialists
- Batch feedback together when possible
- Allow significant revelations to trigger additional rounds
- User controls iteration decisions

## Solution: User-Controlled Checkpoints with Feedback Accumulation

### Core Architecture

**Pattern:** User-Controlled Checkpoints with Parallel Execution

**Design Principles:**
1. **Parallel execution** - All specialists run simultaneously to minimize wall-clock time
2. **Explicit checkpoints** - Clear moments for user to provide feedback
3. **User controls iterations** - User decides if new context warrants another round
4. **Nothing gets lost** - All feedback captured in persistent context document
5. **Circuit breakers** - Prevent endless loops while allowing necessary iteration

### Key Innovation: scenario_context.md

Create a cumulative feedback file that grows throughout the scenario:

**File:** `scenarios/active/SCENARIO-YYYY-NNN/scenario_context.md`

**Contents:**
```markdown
# Scenario Context Updates

This file captures user feedback and clarifications that emerge during scenario planning.
Specialists in later rounds read this to understand evolved context.

## Phase 2 - User Feedback (2025-11-21 14:30)
- **Correction:** Revenue is $900M, not $850M (10% higher than initial)
- **New context:** We're in acquisition talks with CompetitorX ($200M deal)
- **Clarification:** Our market position is weaker in Southeast region

## Phase 3 Round 1 - User Feedback (2025-11-21 15:15)
- **Strategic shift:** Board just approved EV pivot strategy (happened yesterday)
- **Correction:** Debt is $150M, not $100M (forgot about recent line of credit)
- **Reaction to economist:** Yes, the debt constraint is real - limits our R&D budget
```

**Purpose:**
- Updated at each checkpoint with timestamped entries
- Read by specialists in subsequent rounds
- Provides audit trail of how understanding evolved
- Ensures no feedback is ever lost

---

## Checkpoint Mechanism

### How Checkpoints Work

**After each specialist round completes:**

**1. Moderator synthesizes**
- Reads all specialist transcripts
- Identifies key themes, agreements, disagreements
- Prepares 2-3 paragraph synthesis

**2. Moderator presents to user:**
```
"Round 1 complete. Here's what the 7 specialists found:

[2-3 paragraph synthesis highlighting key insights and tensions]

Quick checkpoint:
- Any corrections to the data they're working with?
- Any new context this triggered for you?
- Any major strategic factors they're missing?

(You can say 'looks good' if nothing significant to add)"
```

**3. User provides feedback**
- Corrections, new context, or "proceed"
- Can be brief or detailed

**4. Moderator captures feedback**
- Updates `scenario_context.md` with timestamped entries
- Specific format: corrections, new context, strategic additions

**5. Moderator evaluates significance:**

**Minor feedback:**
- Small data corrections (<20% changes)
- Clarifications that don't change analysis direction
- Refinements to existing information

**Major feedback:**
- New strategic factors
- Data corrections >20%
- Information that contradicts specialist assumptions
- Game-changing revelations

**6. Moderator decision:**

**If minor:**
```
"Got it - I'll incorporate this in the next round/synthesis"
```

**If major:**
```
"This is significant - should I run another round so specialists can
analyze with this new context? (Will take ~15 min)"
```

**7. User decides:**
- "Yes, one more round" → Specialists re-invoked with updated context
- "No, just incorporate it" → Moderator synthesizes with specialist insights + user feedback

---

## Phase-by-Phase Implementation

### Phase 2: Predetermined Elements

**Round 1:**
- Invoke all 7 specialists in parallel (isolated)
- Each reads: company.md, focal_question.md, scenario_context.md
- Each creates: economist_round1_full.md, economist_round1_summary.md
- Wall time: ~10-15 minutes

**Checkpoint 1:**
- Moderator synthesizes Round 1
- Presents to user: "Here's what's predetermined according to specialists..."
- User provides feedback → captured in scenario_context.md
- Moderator evaluates: minor or major?

**Decision:**
- **If minor OR user says "proceed":** Move to final synthesis
- **If major AND user wants iteration:** Round 2

**Round 2 (optional):**
- Invoke specialists with: their Round 1 full + scenario_context.md
- Specialists refine analysis with new context
- Create economist_round2_full.md, economist_round2_summary.md
- Wall time: ~10-15 minutes

**Final synthesis:**
- Moderator creates predetermined_elements.md
- Incorporates latest specialist round + all user feedback

**Cost:**
- Minimum: 7 invocations (1 round)
- Maximum: 14 invocations (2 rounds)

---

### Phase 3: Critical Uncertainties

**Round 1:**
- All 7 specialists in parallel (isolated)
- Read: company.md, focal_question.md, predetermined_elements.md, **scenario_context.md**
- Create Round 1 transcripts
- Wall time: ~10-15 minutes

**Checkpoint 1:**
- Moderator synthesizes
- User provides feedback → scenario_context.md updated
- Moderator evaluates significance

**Round 2 (planned - part of progressive convergence):**
- All 7 specialists in parallel
- Read: their Round 1 full + all Round 1 summaries + **latest scenario_context.md**
- Progressive convergence: see cross-domain insights + user feedback
- Create Round 2 transcripts
- Wall time: ~10-15 minutes

**Checkpoint 2:**
- Moderator presents synthesis
- "Does this capture the critical uncertainties? Anything missing?"
- User feedback captured

**Decision:**
- **If user says "complete":** Move to final synthesis
- **If major gaps AND user wants iteration:** Optional Round 3

**Round 3 (optional):**
- Relevant specialists only (not necessarily all 7)
- Address specific gaps identified
- Wall time: ~10-15 minutes

**Final synthesis:**
- Create critical_uncertainties.md
- Select 2-3 scenario axes

**Cost:**
- Minimum: 14 invocations (2 rounds, standard)
- Maximum: 21 invocations (3 rounds with user iteration)

---

### Phase 4: Scenario Development

**Follows same checkpoint pattern:**
- Round 1 → Checkpoint → Optional iteration
- Round 2 (cluster) → Checkpoint → Optional iteration
- Round 3 (challenge) → Final checkpoint

**Cost:**
- Minimum: 21 invocations (3 rounds, standard)
- Maximum: 28 invocations (4 rounds with user iteration)

---

### Phases 5-6: Signals and Strategy

**Each follows checkpoint pattern:**
- Round 1 → Checkpoint → Optional Round 2
- Read scenario_context.md to see all accumulated feedback

**Cost per phase:**
- Minimum: 7 invocations (1 round)
- Maximum: 14 invocations (2 rounds)

---

## Circuit Breakers and Completion Criteria

### Hard Limits

**Maximum rounds per phase:**
- **Phase 2:** 2 rounds max (initial + 1 optional)
- **Phase 3:** 3 rounds max (initial + convergence + 1 optional)
- **Phase 4:** 4 rounds max (standard 3 + 1 optional)
- **Phases 5-6:** 2 rounds max each

**Total system maximum:** ~90 specialist invocations (vs. standard ~70)

### Soft Signals (Moderator Prompts)

After each potential additional round, moderator asks:

```
"We've completed [N] rounds on [Phase]. The synthesis shows [summary].

Before another round:
- What specific gap would another round address?
- Do you have new context that changes the analysis direction?
- Or should we proceed with what we have?

(Context you provide now will carry forward to future phases even
if we don't re-run this round)"
```

### Completion Criteria

Phase is complete when **either**:

1. **User confirms:** "Yes, this captures everything I'm thinking"
2. **User opts out of iteration:** "No more rounds, let's proceed"
3. **Hard limit reached:** Max rounds hit
   - Moderator notes in synthesis: "Additional user context captured in scenario_context.md but not re-analyzed by specialists due to round limit"

### Key Principle: User Feedback is NEVER Lost

Even if we don't re-run specialists:
- Feedback goes into scenario_context.md
- Future phase specialists see it
- Moderator incorporates it in synthesis
- Audit trail preserved

### Escape Hatches

User can always say:
- **"Skip the checkpoint, I'm good"** → Move to next phase immediately
- **"Pause here, I need to think"** → Moderator waits
- **"Actually, run one more round"** → Moderator accommodates (within hard limits)

---

## Implementation Changes

### 1. Create scenario_context.md Template

**New file:** `templates/scenario_context_template.md`

```markdown
# Scenario Context Updates

This file captures user feedback and clarifications that emerge during scenario planning.
Specialists in later rounds read this to understand evolved context.

## Instructions for Moderator
- Add timestamped entries after each checkpoint
- Be specific about what changed and why it matters
- Distinguish corrections, new context, and reactions
- Format: "## Phase [N] Round [N] - User Feedback (YYYY-MM-DD HH:MM)"

---

## Initial Context (Phase 0)

[Company.md provides baseline - updates below track evolution]

---

[Entries added chronologically as feedback emerges]
```

**Created by:** scenario-init.sh (empty template)
**Updated by:** Moderator at each checkpoint

---

### 2. Update Moderator Prompt - Add Checkpoint Protocol

**Add to moderator.md after each phase's specialist invocation sections:**

```markdown
### Checkpoint After Round [N]

**Your tasks:**

1. **Synthesize specialist insights** (2-3 paragraphs)
   - Key themes across specialists
   - Notable agreements and disagreements
   - Questions or gaps identified

2. **Present to user:**

"Round [N] complete. Here's what specialists found:

[synthesis]

Quick checkpoint:
- Any corrections to data they're working with?
- Any new context this triggered?
- Major factors they're missing?

(Say 'looks good' if nothing significant)"

3. **Capture user feedback:**

If user provides feedback:
- Update scenarios/active/SCENARIO-ID/scenario_context.md
- Add new section with timestamp
- Format:
  ```
  ## Phase [N] Round [N] - User Feedback (2025-11-21 14:30)
  - **Correction:** [What changed and from what to what]
  - **New context:** [Strategic factors not previously mentioned]
  - **Clarification:** [Refinements to understanding]
  - **Reaction:** [Responses to specialist insights]
  ```

4. **Evaluate significance:**

**Minor feedback (incorporate without re-round):**
- Data corrections <20%
- Clarifications that don't change direction
- Refinements to existing information

**Major feedback (consider re-round):**
- New strategic factors
- Data corrections >20%
- Contradicts specialist assumptions
- Game-changing revelations

5. **If major feedback, ask user:**

"This is significant - should I run another round so specialists
can analyze with this new context? (Will take ~15 minutes)"

Wait for user decision.

6. **If user wants iteration:**
- Check round limit (Phase 2: max 2, Phase 3: max 3, etc.)
- If within limit: Re-invoke specialists
- Specialists read: their previous full transcript + scenario_context.md
- Mark as Round [N+1]

7. **If user says proceed or feedback is minor:**
- Continue to final synthesis or next phase
- Incorporate user feedback in your synthesis
- Note in synthesis: "User feedback from checkpoints incorporated"

8. **Update metadata.json:**

Add checkpoint record:
```json
{
  "phase_N_checkpoints": [
    {
      "round": 1,
      "timestamp": "2025-11-21T14:30:00Z",
      "user_feedback": "Provided corrections and new acquisition context",
      "significance": "major",
      "user_decision": "proceed without re-round"
    }
  ]
}
```

9. **Use TodoWrite to track:**
- [x] Round N specialists completed
- [x] Checkpoint presented to user
- [x] User feedback captured
- [ ] Round N+1 (if applicable)
- [ ] Final synthesis
```

---

### 3. Update Specialist Invocation Pattern

**Change ALL specialist invocations to include scenario_context.md:**

**Before:**
```
Read prior work:
- scenarios/active/SCENARIO-2025-001/company.md
- scenarios/active/SCENARIO-2025-001/focal_question.md
```

**After:**
```
Read prior work and accumulated context:
- scenarios/active/SCENARIO-2025-001/company.md
- scenarios/active/SCENARIO-2025-001/focal_question.md
- scenarios/active/SCENARIO-2025-001/scenario_context.md (user feedback and clarifications)
- [phase-specific files]

IMPORTANT: scenario_context.md contains user feedback that emerged during
scenario planning. This represents their evolved understanding - treat it as
authoritative corrections and additions to initial context.
```

**This applies to:**
- All phases (2-6)
- All rounds (1, 2, 3)
- All specialists

---

### 4. Update scenario-init.sh

**Add scenario_context.md creation:**

```bash
# Create scenario_context.md from template
cp templates/scenario_context_template.md "$SCENARIO_DIR/scenario_context.md"

# Add initial timestamp
cat >> "$SCENARIO_DIR/scenario_context.md" << EOF

## Scenario Initialized ($(date -u +"%Y-%m-%d %H:%M"))

Initial context captured in company.md.
User feedback will be added below as scenario planning progresses.

---
EOF
```

---

### 5. Update metadata.json Structure

**Add checkpoint tracking fields:**

```json
{
  "scenario_id": "SCENARIO-2025-001",
  "phase": "predetermined",
  "checkpoints": {
    "phase_2": [
      {
        "round": 1,
        "timestamp": "2025-11-21T14:30:00Z",
        "user_feedback_provided": true,
        "significance": "major",
        "user_decision": "proceed without re-round",
        "context_file_updated": true
      }
    ],
    "phase_3": [
      {
        "round": 1,
        "timestamp": "2025-11-21T15:15:00Z",
        "user_feedback_provided": true,
        "significance": "minor",
        "user_decision": "proceed",
        "context_file_updated": true
      },
      {
        "round": 2,
        "timestamp": "2025-11-21T15:45:00Z",
        "user_feedback_provided": false,
        "user_decision": "complete",
        "context_file_updated": false
      }
    ]
  },
  "total_rounds_by_phase": {
    "phase_2": 1,
    "phase_3": 2,
    "phase_4": 3
  }
}
```

---

## Success Metrics

### Completeness
- **Target:** User says "yes, they captured everything" at scenario completion
- **Measure:** Post-scenario feedback question
- **Failure:** User feels important context was missed

### Efficiency
- **Target:** Average <3 rounds per phase (most phases use standard rounds)
- **Measure:** Track actual rounds used vs. standard rounds
- **Warning:** If averaging >3 rounds, checkpoints may be too granular

### User Time
- **Target:** <20 minutes wall time per round (parallel execution)
- **Measure:** Timestamp between round start and checkpoint presentation
- **Failure:** User waiting >30 minutes per round

### Iteration Rate
- **Target:** 20-30% of checkpoints trigger additional rounds
- **Measure:** user_decision = "run another round" vs. "proceed"
- **Too low (<10%):** Checkpoints may be unnecessary overhead
- **Too high (>50%):** Initial context gathering may be insufficient

---

## Trade-offs and Alternatives Considered

### Alternative 1: No Checkpoints (Rejected)

**Approach:** User feedback goes to moderator only, never back to specialists

**Rejected because:**
- Doesn't meet completeness goal
- Specialists work with incomplete information
- User feels unheard

### Alternative 2: Checkpoint After Every Specialist (Rejected)

**Approach:** Stop after each specialist completes for user feedback

**Rejected because:**
- Terrible user experience (7 interruptions per round!)
- Loses parallel execution benefits
- User waiting time unacceptable

### Alternative 3: Moderator Decides Everything (Rejected)

**Approach:** Moderator evaluates significance, decides whether to re-run without asking user

**Rejected because:**
- User doesn't control their own time
- Moderator judgment may not match user priorities
- Removes user agency

### Alternative 4: Unlimited Rounds (Rejected)

**Approach:** No circuit breakers, iterate until user says "done"

**Rejected because:**
- Risk of endless loops
- No forcing function for completeness
- Could be extremely expensive

---

## Implementation Sequence

### Phase 1: Templates and Infrastructure
1. Create scenario_context_template.md
2. Update scenario-init.sh to create scenario_context.md
3. Update metadata.json schema

### Phase 2: Moderator Prompt Updates
1. Add checkpoint protocol to each phase section
2. Update specialist invocation patterns to include scenario_context.md
3. Add significance evaluation guidance
4. Add TodoWrite tracking for checkpoints

### Phase 3: Testing
1. Test Phase 2 with checkpoint (1 round + optional iteration)
2. Test Phase 3 with checkpoint (2 rounds + optional iteration)
3. Verify scenario_context.md updates correctly
4. Verify metadata.json checkpoint tracking

### Phase 4: Documentation
1. Update CLAUDE.md with checkpoint workflow
2. Document for users: "How checkpoints work"
3. Add checkpoint examples to moderator training

---

## Future Enhancements (Out of Scope)

### Automated Significance Detection
- Use LLM to evaluate user feedback significance automatically
- Compare new context against specialist assumptions
- Recommend (but don't decide) whether to iterate

### Differential Re-invocation
- Instead of all 7 specialists, only re-invoke those affected by new context
- Example: If new context is purely economic, only re-invoke economist + contrarian
- Saves cost but requires sophisticated routing logic

### Context Diff Highlighting
- Show specialists exactly what changed from previous round
- "Previous context said X, new context says Y"
- Helps specialists focus on what's new

### User Feedback Templates
- Structured feedback form: corrections, new factors, clarifications
- Makes it easier for users to provide complete feedback
- Enables better automated significance detection

---

## Conclusion

This design balances:
- ✅ **Completeness** through persistent scenario_context.md and checkpoints
- ✅ **User time** through parallel execution and user-controlled iteration
- ✅ **No endless loops** through hard limits and soft prompts
- ✅ **User agency** through explicit decision points

The key innovation is **scenario_context.md** - a cumulative feedback file that ensures nothing is ever lost, even if we don't re-run specialists. Combined with user-controlled checkpoints, this creates a flexible, efficient system that adapts to the scenario's needs while respecting the user's time.

**Next step:** Implementation following the sequence above.
