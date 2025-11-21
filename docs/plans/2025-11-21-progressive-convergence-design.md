# Progressive Convergence Design for Shell Scenario Panel

## Design Date: 2025-11-21

## Executive Summary

This design implements **progressive convergence** - a multi-round specialist collaboration pattern that balances independent thinking with cross-domain integration. Based on research into Shell's actual methodology and first-principles reasoning about expert collaboration, this approach:

- **Avoids order effects** through parallel Round 1 isolation
- **Enables integration** through progressive exposure to other specialists' thinking
- **Preserves divergence** by treating disagreements as valuable scenario inputs
- **Scales complexity** with collaboration intensity matching phase needs

## Problem Statement

**Original concern:** In survey research, question order affects responses. Could the order of specialist consultation create bias in scenario development?

**Discovery:** The current system uses isolated consultation with no convergence rounds, creating two problems:
1. Heavy moderator synthesis burden (single point of failure)
2. No cross-pollination between specialists (missed insights)

**Research findings:**
- Shell's original methodology (Pierre Wack) used **parallel individual work** followed by team synthesis
- Modern workshop approaches require extensive bias prevention
- First principles analysis recommends **parallel-then-converge** pattern

## Design Principles

### 1. Progressive Exposure by Information Depth

Specialists are exposed to increasing amounts of information across rounds:
- **Round 1:** Complete isolation (0% exposure)
- **Round 2:** Summary exposure from all specialists (~700 words total)
- **Round 3:** Full transcript exposure from all specialists (~3500+ words)

### 2. Divergence as Feature, Not Bug

Disagreements between specialists reveal critical uncertainties:
- Convergence → Predetermined elements
- Divergence → Potential scenario axes
- Contradictions → Critical uncertainties

**DO NOT force consensus.** Preserve multiple perspectives in multiple scenarios.

### 3. All Specialists, Every Phase

All 7 specialists (6 domain + 1 researcher) engaged in Phases 2-6:
- Economist, Geopolitician, Ecologist, Futurist, Anthropologist, Contrarian, Researcher
- Consistent roster builds cumulative context
- Different collaboration patterns per phase, not different specialists

### 4. File-Based Information Flow

No context window flooding:
- Specialists read/write files using Read/Write tools
- Each specialist creates dual files per round: `_full.md` and `_summary.md`
- Moderator orchestrates file paths, specialists handle content

### 5. Agent Identity Priming

Every specialist invocation loads full identity from agent profile:
- `prompts/specialists/[specialist].md` contains complete character/expertise
- Task tool loads this automatically
- Ensures consistent voice/perspective across all rounds

## Complete Phase-by-Phase Design

### Phase 0: Company Deep Dive (Enhanced)

**Objective:** Create comprehensive company profile with financial and operational detail

**Moderator Actions:**

1. **Initial Context Gathering**
   - Ask: Company name, industry, strategic challenge

2. **Real-Time Research-Informed Interrogation**
   - Use `pp-cli` to research company/industry
   - Example:
     ```bash
     pp --no-interactive "[Company] financial performance 2024" --output json
     pp --no-interactive "[Industry] trends challenges 2024-2025" --output json
     ```
   - Ask informed follow-up questions based on research

3. **Structured Data Capture**
   - Financial: Revenue, EBITDA, margins (gross/net), debt ratios
   - Operational: Geography, employee count, market share
   - Strategic: Competitive position, key challenges, differentiation
   - Industry context: Trends, regulations, disruptions (from pp-cli)

4. **Create company.md**
   - File: `scenarios/active/SCENARIO-YYYY-NNN/company.md`
   - Template includes all structured sections
   - 500-1000 words, research-backed

**Output:** Rich company.md that specialists will reference in all phases

---

### Phase 0 (continued): Discovery Rounds (Keep Current)

**Current design already implements multi-round discovery**
- All 6 domain specialists
- Round 1: Isolated research using pp-cli
- Round 2+: With prior transcripts
- Output: Discovery transcripts + scenario suggestions

**Enhancement:** Explicitly label Round 1 as isolated

---

### Phase 1: Focal Question

**Pattern:** Moderator-led dialogue with user (minimal specialists)

**Moderator Actions:**
- Ask targeted questions about decision context
- Clarify time horizon (5 years? 10? 20?)
- Define scope (industry, region, global?)
- May consult 0-2 specialists for domain context (single round)

**Output:** `focal_question.md`

---

### Phase 2: Predetermined Elements

**Pattern:** 1 round, isolated consultation (all 7 specialists)

**Why 1 round:** Predetermined elements are domain-specific facts requiring minimal cross-domain integration at this stage.

**Moderator Invocation (Example for Economist):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 2: Predetermined Elements

Read company profile:
scenarios/active/SCENARIO-2025-001/company.md

Read focal question:
scenarios/active/SCENARIO-2025-001/focal_question.md

Identify predetermined elements from economic perspective:
- What debt structures/financial obligations constrain the future?
- What economic trends are already locked in?
- What capital flows are inevitable?

Create TWO files:

1. Full analysis:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_full.md
(500+ words with deep economic reasoning)

2. Summary for cross-reading:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_summary.md
Format:
## KEY POINTS (3-5 bullets)
- Point 1
- Point 2

## EXECUTIVE SUMMARY (100 words max)
[Summary text]
")
```

**All 7 specialists consulted in parallel** (7 Task invocations)

**File Structure:**
```
conversations/
├── economist_round1_full.md
├── economist_round1_summary.md
├── geopolitician_round1_full.md
├── geopolitician_round1_summary.md
├── ecologist_round1_full.md
├── ecologist_round1_summary.md
├── futurist_round1_full.md
├── futurist_round1_summary.md
├── anthropologist_round1_full.md
├── anthropologist_round1_summary.md
├── contrarian_round1_full.md
├── contrarian_round1_summary.md
├── researcher_round1_full.md (only if knowledge gaps identified)
└── researcher_round1_summary.md
```

**Moderator Synthesis:**
- Read all Round 1 full transcripts
- Synthesize into `predetermined_elements.md`
- Present to user for validation

**Cost:** 7 specialist invocations

---

### Phase 3: Critical Uncertainties

**Pattern:** 2 rounds (parallel-then-converge) - all 7 specialists

**Why 2 rounds:** Finding scenario axes REQUIRES seeing across domains. Integration is critical here.

#### Round 1: Isolated Identification

**Moderator Invocation (Example for Economist):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 3: Critical Uncertainties - ROUND 1

Read company profile and prior phase work:
- scenarios/active/SCENARIO-2025-001/company.md
- scenarios/active/SCENARIO-2025-001/focal_question.md
- scenarios/active/SCENARIO-2025-001/predetermined_elements.md

Identify critical uncertainties from economic perspective:
- What economic factors could go multiple ways?
- What regime changes are possible but uncertain?
- What financial/monetary uncertainties matter most?

IMPORTANT: Work independently. You will NOT see other specialists' work until Round 2.

Create TWO files:

1. Full analysis:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_full.md

2. Summary:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_summary.md
")
```

**All 7 specialists in parallel** (7 invocations)

#### Round 2: Convergence with Summary Exposure

**Moderator Invocation (Example for Economist):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 3: Critical Uncertainties - ROUND 2

Read YOUR full Round 1 analysis:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_full.md

Read SUMMARIES from all 7 specialists:
- conversations/economist_round1_summary.md (yours)
- conversations/geopolitician_round1_summary.md
- conversations/ecologist_round1_summary.md
- conversations/futurist_round1_summary.md
- conversations/anthropologist_round1_summary.md
- conversations/contrarian_round1_summary.md
- conversations/researcher_round1_summary.md

Your task: Refine your analysis based on high-level insights from other domains.

FOCUS ON:
- **Convergence:** Where do uncertainties cluster across domains?
- **Divergence:** Where do specialists see different possibilities?
- **Contradictions:** Where do specialists fundamentally disagree?

IMPORTANT: Disagreements are VALUABLE - they reveal what's genuinely uncertain.
Do NOT force consensus. Surface divergence clearly.

Create TWO files:

1. Full Round 2 analysis:
scenarios/active/SCENARIO-2025-001/conversations/economist_round2_full.md

2. Summary:
scenarios/active/SCENARIO-2025-001/conversations/economist_round2_summary.md
")
```

**All 7 specialists in parallel** (7 invocations)

**File Structure After Round 2:**
```
conversations/
├── economist_round1_full.md
├── economist_round1_summary.md
├── economist_round2_full.md
├── economist_round2_summary.md
├── [same pattern for all 7 specialists]
```

**Moderator Synthesis:**
- Read all Round 2 full transcripts
- Identify:
  - **Convergence** → Strengthen predetermined elements or validate assumptions
  - **Divergence** → Candidate scenario axes
  - **Contradictions** → Critical uncertainties
- Select 2-3 scenario axes
- Synthesize into `critical_uncertainties.md`
- Present to user for validation

**Cost:** 14 specialist invocations (7 × 2 rounds)

---

### Phase 4: Scenario Development

**Pattern:** 3 rounds (cluster-based collaboration) - all 7 specialists

**Why 3 rounds:** Building narratives benefits from deep collaboration. Most intensive phase.

#### Round 1: Independent Scenario Sketches

**Moderator Invocation (Example for Economist):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 4: Scenario Development - ROUND 1

Read all prior work:
- company.md
- focal_question.md
- predetermined_elements.md
- critical_uncertainties.md (includes scenario axes)

Using the scenario axes [Axis 1] and [Axis 2], explore the scenario quadrants:
- Scenario A: [High X, High Y]
- Scenario B: [High X, Low Y]
- Scenario C: [Low X, High Y]
- Scenario D: [Low X, Low Y]

From your economic lens, what does each scenario look like?
What economic structures, dynamics, and outcomes characterize each?

Work independently - this is divergent scenario exploration.

Create TWO files:

1. Full analysis:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_full.md

2. Summary:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_summary.md
")
```

**All 7 specialists in parallel** (7 invocations)

#### Round 2: Cluster Formation and Refinement

**Moderator analyzes Round 1 outputs and identifies natural clusters:**

Example clustering:
- **Cluster A:** "Tech-Enabled Growth" (futurist + economist insights)
- **Cluster B:** "Ecological Constraint" (ecologist + anthropologist insights)
- **Cluster C:** "Geopolitical Fragmentation" (geopolitician + contrarian insights)
- **Bridge:** Researcher synthesizes across clusters

**Moderator Invocation (Example for specialists in Cluster A):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 4: Scenario Development - ROUND 2 (Cluster Refinement)

Read YOUR full Round 1:
scenarios/active/SCENARIO-2025-001/conversations/economist_round1_full.md

Read FULL TRANSCRIPTS from your cluster members:
- conversations/futurist_round1_full.md
- conversations/economist_round1_full.md

Read SUMMARIES from other clusters:
- conversations/ecologist_round1_summary.md (Cluster B)
- conversations/anthropologist_round1_summary.md (Cluster B)
- conversations/geopolitician_round1_summary.md (Cluster C)
- conversations/contrarian_round1_summary.md (Cluster C)

Your cluster is developing the 'Tech-Enabled Growth' scenario.

Refine and integrate with your cluster members. Build a coherent scenario narrative
that combines economic and technological perspectives.

Create TWO files:

1. Full Round 2 analysis:
scenarios/active/SCENARIO-2025-001/conversations/economist_round2_full.md

2. Summary:
scenarios/active/SCENARIO-2025-001/conversations/economist_round2_summary.md
")
```

**All 7 specialists in parallel, but reading different clusters** (7 invocations)

#### Round 3: Cross-Cluster Integration and Challenge

**Moderator Invocation (Example for Economist):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 4: Scenario Development - ROUND 3 (Final Integration)

Read YOUR full history:
- conversations/economist_round1_full.md
- conversations/economist_round2_full.md

Read ALL specialists' full transcripts from Rounds 1 and 2:
- conversations/*_round1_full.md (all 7)
- conversations/*_round2_full.md (all 7)

This is final scenario integration.

Tasks:
1. Identify cross-domain patterns and feedback loops
2. Find contradictions between scenarios that need resolution
3. Ensure economic logic is sound across all 3-4 scenarios
4. Surface blind spots or implausible assumptions

Create final analysis:
scenarios/active/SCENARIO-2025-001/conversations/economist_round3_final.md
(No summary needed - this is final output)
")
```

**All 7 specialists in parallel** (7 invocations)

**Special Round 3 Role for Contrarian:**
```
Task("contrarian", "SCENARIO: SCENARIO-2025-001
PHASE 4: Scenario Development - ROUND 3 (Challenge and Stress-Test)

[Same reading instructions]

Your specific task as contrarian:
1. Stress-test plausibility of all scenarios
2. Identify hidden assumptions or groupthink
3. Find scenarios that are too comfortable or obvious
4. Propose alternative scenario framings if current set misses something critical

Challenge the scenarios aggressively. Your job is to break comfortable thinking.

Create final analysis:
scenarios/active/SCENARIO-2025-001/conversations/contrarian_round3_final.md
")
```

**File Structure After Round 3:**
```
conversations/
├── economist_round1_full.md
├── economist_round1_summary.md
├── economist_round2_full.md
├── economist_round2_summary.md
├── economist_round3_final.md
├── [same pattern for all 7 specialists]
```

**Moderator Synthesis:**
- Read all Round 3 final transcripts
- Integrate into 3-4 scenario narratives
- Create separate files:
  - `scenarios/scenario_1_[name].md`
  - `scenarios/scenario_2_[name].md`
  - `scenarios/scenario_3_[name].md`
  - `scenarios/scenario_4_[name].md`
- Each scenario: Name, narrative, implications, internal logic
- Present to user for validation

**Cost:** 21 specialist invocations (7 × 3 rounds)

---

### Phase 5: Early Warning Signals

**Pattern:** 1 round, isolated (all 7 specialists)

**Why 1 round:** Each specialist identifies observable indicators from their domain. Less need for convergence.

**Moderator Invocation (Example for Economist):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 5: Early Warning Signals

Read all completed scenarios:
- scenarios/scenario_1_[name].md
- scenarios/scenario_2_[name].md
- scenarios/scenario_3_[name].md
- scenarios/scenario_4_[name].md

For each scenario, identify economic early warning signals:
- What observable indicators would signal this scenario is unfolding?
- What metrics should we track?
- What events would be diagnostic?

Make signals:
- Specific and measurable
- Observable in advance
- Clearly linked to scenario logic

Create:
scenarios/active/SCENARIO-2025-001/conversations/economist_signals.md
")
```

**All 7 specialists in parallel** (7 invocations)

**Moderator Synthesis:**
- Read all specialist signal analyses
- Integrate into each scenario document
- Add "Early Warning Signals" section to each scenario
- Present to user for validation

**Cost:** 7 specialist invocations

---

### Phase 6: Strategy Testing

**Pattern:** 1 round, structured challenge (all 7 specialists)

**Why 1 round:** Testing completed work, not building new insights. Challenge-focused.

**Moderator Invocation (Example for Economist):**
```
Task("economist", "SCENARIO: SCENARIO-2025-001
PHASE 6: Strategy Testing

Read all scenarios with early warning signals:
- scenarios/scenario_1_[name].md
- scenarios/scenario_2_[name].md
- scenarios/scenario_3_[name].md
- scenarios/scenario_4_[name].md

The user is considering these strategies:
[User's proposed strategies]

For each strategy, analyze from economic perspective:
- How does it perform in each scenario?
- What economic risks/opportunities does it face?
- Are there economic fragilities or strengths?
- Which strategies are economically robust across scenarios?
- Which require adaptive responses?

Create:
scenarios/active/SCENARIO-2025-001/conversations/economist_strategy.md
")
```

**All 7 specialists in parallel** (7 invocations)

**Moderator Synthesis:**
- Read all specialist strategy analyses
- Identify:
  - **Robust strategies:** Work well across all scenarios
  - **Adaptive strategies:** Position for flexibility
  - **Risky strategies:** Fail in some scenarios
- Synthesize into `strategy_analysis.md`
- Present to user for final validation

**Cost:** 7 specialist invocations

---

## Total Specialist Invocation Cost

| Phase | Pattern | Invocations |
|-------|---------|------------|
| Phase 0 | Discovery (existing) | ~12-14 |
| Phase 1 | Moderator-led | 0-2 |
| Phase 2 | 1 round isolated | 7 |
| Phase 3 | 2 rounds convergence | 14 |
| Phase 4 | 3 rounds cluster | 21 |
| Phase 5 | 1 round isolated | 7 |
| Phase 6 | 1 round challenge | 7 |
| **Total** | | **~68-72** |

**Current system:** ~25-30 invocations
**New system:** ~70 invocations
**Cost increase:** ~2.5x
**Quality improvement:** Distributed synthesis, cross-domain integration, bias prevention

---

## Hook-Based File Enforcement

### Configuration in .claude/config.json

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Task",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/pre-specialist.sh"
      }]
    }],
    "SubagentStop": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": ".claude/hooks/post-specialist.sh"
      }]
    }]
  }
}
```

### Pre-Specialist Hook

**File:** `.claude/hooks/pre-specialist.sh`

```bash
#!/bin/bash
# Pre-specialist invocation hook

echo "🔧 Preparing specialist invocation..."
echo "   Scenario: $SCENARIO_ID"
echo "   Phase: $CURRENT_PHASE"
echo "   Round: $CURRENT_ROUND"
echo ""
echo "   Files to be created:"
echo "   - conversations/${SPECIALIST}_round${ROUND}_full.md"
echo "   - conversations/${SPECIALIST}_round${ROUND}_summary.md"
echo ""
```

### Post-Specialist Hook

**File:** `.claude/hooks/post-specialist.sh`

```bash
#!/bin/bash
# Post-specialist verification hook

SCENARIO_DIR="scenarios/active/$SCENARIO_ID"
SPECIALIST="$LAST_SPECIALIST"
ROUND="$CURRENT_ROUND"

echo "✅ Specialist completed: $SPECIALIST"
echo ""
echo "📝 Verifying outputs..."

# Check for required files
FULL_FILE="$SCENARIO_DIR/conversations/${SPECIALIST}_round${ROUND}_full.md"
SUMMARY_FILE="$SCENARIO_DIR/conversations/${SPECIALIST}_round${ROUND}_summary.md"

ERRORS=0

if [ ! -f "$FULL_FILE" ]; then
    echo "❌ MISSING: $FULL_FILE"
    ((ERRORS++))
else
    WORD_COUNT=$(wc -w < "$FULL_FILE" | tr -d ' ')
    echo "✓ Full transcript: $WORD_COUNT words"

    if [ "$WORD_COUNT" -lt 100 ]; then
        echo "⚠️  Warning: Full transcript is short (< 100 words)"
    fi
fi

if [ ! -f "$SUMMARY_FILE" ]; then
    echo "❌ MISSING: $SUMMARY_FILE"
    ((ERRORS++))
else
    SUMMARY_WORDS=$(wc -w < "$SUMMARY_FILE" | tr -d ' ')
    echo "✓ Summary: $SUMMARY_WORDS words"

    if [ "$SUMMARY_WORDS" -gt 200 ]; then
        echo "⚠️  Warning: Summary is long (> 200 words)"
    fi
fi

echo ""

if [ "$ERRORS" -gt 0 ]; then
    echo "❌ Validation failed with $ERRORS error(s)"
    echo "⚠️  Moderator should re-invoke specialist with explicit file path reminder"
else
    echo "✅ All required files created successfully"
fi

exit 0
```

**Note:** Claude Code hooks don't have access to environment variables like `$SCENARIO_ID` by default. The moderator will need to set these or hooks should detect them from file system.

---

## Anti-Groupthink Safeguards

### Built-In Structural Safeguards

1. **Round 1 Isolation** - Prevents anchoring and premature convergence
2. **Summary-First Exposure** - Round 2 gets high-level patterns, not detailed framings
3. **Divergence Prompts** - Explicit instructions to value disagreement
4. **Contrarian Role** - Systematic challenge mechanism
5. **Multiple Scenarios** - Divergent views preserved in different scenarios, not forced into one

### Prompts for Round 2 & 3

**Anti-Groupthink Language to Include:**

```
IMPORTANT: Your task is NOT to reach consensus.

CONVERGENCE: Where do insights from different domains reinforce each other?
→ May indicate predetermined elements or robust assumptions

DIVERGENCE: Where do specialists see different possibilities?
→ May indicate critical uncertainties worth exploring

CONTRADICTION: Where do specialists fundamentally disagree?
→ Often reveals scenario axes - different scenarios can embody different views

Disagreements are VALUABLE - they reveal what's genuinely uncertain.
Surface contradictions clearly rather than resolving them prematurely.

If you find yourself agreeing with everyone, ask:
- Am I losing my distinct domain perspective?
- Am I being influenced by framing rather than facts?
- What would my domain expertise say independently?
```

### Moderator's Anti-Groupthink Checklist

After each convergence round, moderator should verify:

- [ ] Are Round 2/3 transcripts substantively different from Round 1? (Not just reworded)
- [ ] Do specialists preserve their distinct domain voices?
- [ ] Are contradictions surfaced explicitly, not papered over?
- [ ] Does the contrarian identify any premature consensus?
- [ ] Are we building multiple scenarios, not converging to one "most likely" future?

---

## Specialist Prompt Enhancement

### Current State

Specialist prompts include:
- Character/persona
- Domain expertise
- Analytical approach
- Communication style

### Enhancement Needed

**Add domain-specific technical language** to activate precise latent space.

**Example Enhancement for Economist:**

**Before:**
```
You analyze debt and financial structures.
```

**After:**
```
You analyze sovereign debt trajectories, corporate leverage ratios, monetary
regime shifts (Bretton Woods → fiat → ?), currency dynamics, capital account
flows, shadow banking systems, and financial fragility indicators like Minsky
moments, balance sheet recessions, and sudden stops.

Your economic frameworks include:
- Modern Monetary Theory vs. Austrian economics vs. Keynesian synthesis
- Debt supercycle dynamics (Ray Dalio)
- Financial instability hypothesis (Hyman Minsky)
- Currency regime history and transition dynamics
- Capital flow impossible trinity (Mundell-Fleming)
```

**Why this matters:**
- Activates specific knowledge domains in the LLM
- Creates more technical, nuanced analysis
- Ensures distinct specialist voices (economist sounds different from anthropologist)
- Better emulates actual domain experts

### Action Item

**Todo added:** "Refine specialist prompts with domain-specific technical language"
- Review all 7 specialist prompts
- Add 2-3 paragraphs of technical terminology per specialist
- Include specific frameworks, models, key thinkers
- Test with sample invocations to verify voice quality

---

## Implementation Sequence

### Phase 1: Foundation (Week 1)

1. **Enhance specialist prompts**
   - Add technical language to all 7 specialists
   - Test invocations to verify distinct voices
   - Update prompts/specialists/*.md files

2. **Create hook scripts**
   - Write .claude/hooks/pre-specialist.sh
   - Write .claude/hooks/post-specialist.sh
   - Update .claude/config.json with hook configuration
   - Test hook execution

3. **Create company.md template**
   - Document structured template
   - Update moderator.md with Phase 0 interrogation guide
   - Add pp-cli research integration instructions

### Phase 2: Phase 2-3 Implementation (Week 2)

4. **Implement Phase 2 (1 round isolated)**
   - Update moderator invocation pattern for dual-file creation
   - Test with sample scenario
   - Verify hooks enforce file creation
   - Validate synthesis quality

5. **Implement Phase 3 (2 rounds convergence)**
   - Create Round 1 isolated invocation pattern
   - Create Round 2 summary-exposure invocation pattern
   - Test progressive convergence flow
   - Validate anti-groupthink prompts work

### Phase 3: Phase 4 Implementation (Week 3)

6. **Implement Phase 4 (3 rounds cluster)**
   - Create Round 1 isolated invocation
   - Design cluster formation logic for moderator
   - Create Round 2 cluster-refinement invocation
   - Create Round 3 full-integration invocation
   - Test complete 3-round flow
   - Validate scenario quality

### Phase 4: Phases 5-6 Implementation (Week 4)

7. **Implement Phase 5 (1 round signals)**
   - Create signal identification invocation
   - Test integration into scenario documents

8. **Implement Phase 6 (1 round strategy)**
   - Create strategy testing invocation
   - Test robust/adaptive strategy identification

### Phase 5: End-to-End Testing (Week 5)

9. **Full scenario development test**
   - Run complete Phase 0 → Phase 6 with real company
   - Measure quality improvements vs. current system
   - Identify rough edges and refinements
   - Document lessons learned

10. **Documentation and training**
    - Update all moderator documentation
    - Create specialist invocation reference guide
    - Document troubleshooting common issues

---

## Success Metrics

### Quality Metrics

- **Diversity:** Are Round 1 transcripts substantively different across specialists?
- **Integration:** Do Rounds 2-3 identify cross-domain patterns not visible in Round 1?
- **Contradiction surfacing:** Are disagreements explicitly documented?
- **Scenario distinctness:** Are the 3-4 final scenarios genuinely different?
- **Blind spot identification:** Does contrarian catch groupthink or comfortable assumptions?

### Process Metrics

- **File creation compliance:** Do specialists create required _full.md and _summary.md files?
- **Word count compliance:** Are full transcripts substantive (>100 words)? Summaries concise (<200 words)?
- **Moderator synthesis efficiency:** Does progressive convergence reduce moderator synthesis burden?
- **User validation pass rate:** Do users validate phase outputs without requiring rework?

### Efficiency Metrics

- **Time to completion:** Phase 0 → Phase 6 elapsed time
- **Specialist invocation count:** Actual vs. planned (~70 invocations)
- **Context window usage:** Are we staying within limits?
- **Re-invocation rate:** How often do specialists need to be re-invoked for missing files?

---

## Risk Mitigation

### Risk: Specialists Don't Create Required Files

**Mitigation:**
- Post-specialist hook catches missing files immediately
- Moderator re-invokes with explicit reminder
- If repeated failures: Flag to user for manual intervention

### Risk: Groupthink in Convergence Rounds

**Mitigation:**
- Round 1 isolation protects initial diversity
- Round 2 summary-only exposure limits anchoring
- Explicit anti-groupthink prompts
- Contrarian systematic challenge
- Moderator checklist verification

### Risk: Context Window Overload

**Mitigation:**
- Dual-file approach (summary separate from full)
- Progressive exposure (summaries first, then full)
- Specialists read files, not receive in prompt
- Clear file reading instructions to avoid unnecessary reads

### Risk: Moderator Synthesis Quality

**Mitigation:**
- Progressive convergence distributes synthesis to specialists
- Round 2-3 specialists do cross-domain integration themselves
- Moderator focuses on identifying patterns, not creating them
- User validation at every phase gate

### Risk: Cost Explosion

**Mitigation:**
- ~70 invocations is predictable and budgetable
- Quality improvement justifies 2.5x cost increase
- Can reduce rounds in non-critical phases if needed
- User controls when to proceed (can stop/adjust)

---

## Future Enhancements (Not in Current Scope)

### Post-Launch Optimizations

1. **Dynamic round adjustment:** Moderator detects low divergence → skip Round 3
2. **Selective specialist invocation:** Some phases might not need all 7
3. **Automated clustering:** Use LLM to cluster Round 1 transcripts for Phase 4
4. **Research logging:** Track all pp-cli queries for transparency
5. **Validation scoring:** Quantify quality metrics automatically

### Advanced Features

1. **Multi-scenario testing:** Run same company through multiple specialists orders, compare results
2. **Historical validation:** Test against past scenarios (e.g., Shell's actual scenarios)
3. **User feedback loop:** Capture which scenarios proved most valuable in decision-making
4. **Scenario updating:** Refresh scenarios as new data emerges (ongoing monitoring)

---

## Conclusion

This progressive convergence design:

✅ **Avoids order effects** through Round 1 parallel isolation
✅ **Enables cross-domain integration** through Rounds 2-3 convergence
✅ **Preserves divergence** by treating disagreements as valuable scenario inputs
✅ **Distributes synthesis** across specialists, reducing moderator burden
✅ **Scales appropriately** with collaboration intensity matching phase complexity
✅ **Based on Shell's actual methodology** (parallel individual work + team synthesis)
✅ **Validated by first principles** (optimal bias/quality trade-off)
✅ **Implementable with Claude Code CLI** (file-based, hook-enforced, agent-profiled)

**Next step:** Proceed to implementation following the phased sequence.
