# Phase 0: Company Discovery - Design Document

**Date:** 2025-11-18
**Status:** IMPLEMENTED - Ready for Production Use (2025-11-18)
**Author:** Claude + Braydon

## Overview

Add a new Phase 0 (Company Discovery) to the Shell Scenario Panel system that:
1. Interviews users about their company through an intelligent discovery loop
2. Has all 6 specialists research company/market context from their domain perspectives
3. Generates AI-recommended focal questions based on discoveries
4. Feeds enriched context into existing Phases 1-6

**Goal:** Transform the system from "develop scenarios given a clear focal question" into "discover the right focal question and develop scenarios grounded in real market conditions."

---

## Phase 0 Workflow: Interleaved Discovery

**Entry Point:**
When user starts new scenario, Dr. Wells asks: **"Do you have a clear focal question, or should I interview you about your company first?"**

### Initial Interview (Mandatory - 2-3 Questions)

Wells asks minimal basics to kick off research:
- Company name and industry
- Size/stage
- Basic business model

Just enough for specialists to start researching.

### Research-Informed Interview Loop

**1. Specialists Research**
- Wells immediately invokes all 6 specialists with what she knows so far
- Each specialist reads `company.md` (current state)
- Each researches from their domain perspective using pp-cli
- Each creates discovery transcript with findings + questions they need answered

**2. Wells Synthesizes**
- Reviews all 6 transcripts
- Identifies common patterns/concerns across specialists
- Identifies specific questions that emerged from research
- Identifies new areas to explore

**3. Wells Asks Follow-ups**
- Asks user questions informed by research findings
- Example: Economist found supply chain stress → Wells asks "Do you source components internationally?"
- Example: Futurist found AI disruption trends → Wells asks "Are you experimenting with AI in your design process?"
- Updates `company.md` with user's answers

**4. Specialists Research Deeper**
- With new answers, specialists research more specifically
- Read updated `company.md`
- Read their own previous discovery transcript (if Round 2+)
- Create updated discovery transcripts

**5. Convergence Check**
- Wells evaluates: "Did new research reveal significant uncertainties?"
- User confirms: "Does this feel comprehensive?"
- If yes to either: Repeat steps 1-4
- If no to both: Generate scenario suggestions

**Key Principle:** The interview is **driven by research findings**, not a pre-planned question list.

---

## Specialist Discovery Prompts

### Central Company File

Wells maintains `company.md` that gets updated throughout discovery:
- After initial questions: basic facts
- After each round: adds user's answers to specialist questions
- Specialists always read current `company.md` before researching

### Discovery Mode Prompt (Simplified)

```
CONTEXT: Phase 0 - Company Discovery (Round [N])

YOUR TASK:
1. Read company.md to understand what we know about this company
2. Research current conditions from your domain expertise
3. Identify critical questions we should ask the user
4. Document your findings and questions in a discovery transcript

Use your professional judgment about what to research.
You're the expert in [your domain] - research what matters from your perspective.

OUTPUT: Create discovery transcript (minimum 100 words) with:
- Your research findings (with pp-cli citations)
- Critical uncertainties or risks you identified from your lens
- Specific questions for the user that would help you assess their strategic position
```

### Specialist Autonomy Examples

**Economist:** Reads "Auto OEM parts manufacturer" → Researches: industry profitability trends, capital intensity, customer concentration risk, commodity price exposure

**Ecologist:** Reads same company → Researches: Manufacturing resource dependencies, waste regulations, circular economy trends, material scarcity

**Contrarian:** Reads same company → Researches: What industry consensus believes, what's being overestimated, what's being ignored

Wells doesn't prescribe WHAT to research - she trusts their expertise.

---

## Company Profile Structure

**File:** `company.md`

Living document that grows throughout Phase 0.

```markdown
# Company Profile: [Company Name]

## Basic Information
- **Industry:** [industry]
- **Stage:** [startup/growth/mature]
- **Size:** [revenue/employees]
- **Business Model:** [description]
- **Geographic Markets:** [markets]
- **Strategic Context:** [user's stated challenge/decision]

## Business Details

### Operations
- [Supply chain, manufacturing, delivery model]

### Market Position
- [Customers, competitors, market share, differentiation]

### Financials
- [Capital structure, profitability, funding, constraints]

### Capabilities
- [Technology, talent, IP, infrastructure, partnerships]

### Constraints & Risks
- [Regulatory, operational, financial, competitive pressures]

## Discovery History
**Round 1:** [Date] - Initial interview completed
**Round 2:** [Date] - Specialist research round 1
**Round 3:** [Date] - Follow-up questions on [topics]
```

**Update Pattern:**
- Wells updates after each user response
- Specialists read before each research round
- By convergence, it's a comprehensive company snapshot
- Becomes reference document for all subsequent scenario phases

---

## Scenario Suggestions Structure

After discovery converges, Wells generates **3-4 recommended focal questions**.

**File:** `scenario_suggestions.md`

```markdown
# Scenario Suggestions for [Company Name]

Based on discovery research by all 6 domain specialists, here are recommended
focal questions for scenario development:

## Suggestion 1: [Memorable Title]
**Focal Question:** "[Specific strategic question with time horizon]"

**Why This Matters:**
[2-3 sentences on why this question emerged from research]
- Economist found: [key economic uncertainty]
- Geopolitician found: [key geopolitical risk]
- Futurist found: [key technology/trend inflection point]

**What This Would Explore:**
[What scenarios around this question would reveal]

---

## Suggestion 2: [Title]
**Focal Question:** "[Question]"
[Same structure]

---

## Suggestion 3: [Title]
[Same structure]

---

## Custom Question
If none of these resonate, provide your own focal question and I'll help refine it.
```

### Example Suggestion (Auto OEM Parts)

```markdown
## Suggestion 1: The EV Transition Timing Question
**Focal Question:** "What business model positioning maximizes our survival odds
given uncertainty about EV transition speed over the next 5 years?"

**Why This Matters:**
- Economist found: EV transition requires 40% more capital investment than ICE retooling
- Futurist found: Adoption forecasts range from 15% to 60% by 2030 (4x variance)
- Geopolitician found: Policy uncertainty (subsidies, tariffs, Chinese competition)
- Contrarian found: Industry consensus may be overestimating transition speed

**What This Would Explore:**
Scenarios where EV adoption is fast vs. slow, and capital markets favor risk vs.
safety - testing whether to invest heavily now, hedge with dual capability, or
stay ICE-focused longer.
```

### Selection Process

Wells identifies questions where:
- Multiple specialists flagged the same uncertainty
- High impact on company's strategic position
- Genuine uncertainty (not predetermined)
- Actionable time horizon (matches company's planning cycle)

User picks one, or provides their own. Wells helps refine before proceeding to Phase 1.

---

## Handoff to Existing Phases

After Phase 0 completes, existing 6-phase workflow proceeds **with enriched context**.

### User Selection
- User picks one of Wells' suggested focal questions, OR
- User provides their own focal question

### Phase 1: Focal Question Refinement (Streamlined)
- Wells presents chosen/provided question
- Offers refinement suggestions based on discovery findings
- Ensures question has: clear decision, time horizon, scope, testable strategies
- Documents in `focal_question.md`
- **Much faster than current Phase 1** - most context already established

### Phase 2-6: Scenario Development (Context-Aware)

Specialists now reference Phase 0 outputs when consulted:

**Prompt Addition for Phases 2-6:**
```
PHASE 0 CONTEXT AVAILABLE:
- company.md (comprehensive company profile)
- phase_0_discovery/research/[your_name]_discovery_roundN.md (your earlier research)

Before analyzing, review these files to ground your analysis in what we
learned about this company.
```

### Example - Phase 2 Predetermined Elements

**Before (current system):**
Economist consulted about predetermined elements, has no company context, asks general questions

**After (with Phase 0):**
Economist reads `company.md`, sees: "60% international suppliers, JIT inventory, 3-week buffer"
Economist reads `economist_discovery.md`, remembers: "Supply chain fragility, capital constraints"
Economist immediately provides: "Predetermined: Rising supplier consolidation will reduce your negotiating power by 2027. Your thin inventory buffers are locked in by facility constraints."

**Key Benefit:**
Specialists don't re-ask basic questions. They build directly on discovery findings. Scenario narratives are specific to THIS company, not generic.

---

## Implementation Changes

### 1. Moderator Prompt (`prompts/moderator.md`)

Add Phase 0 section to Dr. Wells' instructions:

```markdown
## Phase 0: Company Discovery

When scenario begins, ask: "Do you have a clear focal question, or should I
interview you about your company first?"

### If User Wants Discovery:

**Initial Interview:**
1. Ask 2-3 basic questions to establish foundation:
   - Company name and industry
   - Size/stage
   - Basic business model
2. Create `company.md` with these basics

**Discovery Loop:**
1. Invoke all 6 domain specialists for discovery research
   - Use Task tool with specialist_name
   - Pass context: "Phase 0 discovery - read company.md and research from your perspective"
2. Validate all 6 discovery transcripts (100+ words each)
3. Synthesize findings into questions for user
4. Ask user targeted follow-up questions
5. Update company.md with answers
6. Evaluate convergence:
   - Did research reveal significant new uncertainties?
   - Does user feel we have comprehensive picture?
   - If no to both: Discovery complete
   - If yes to either: Repeat steps 1-5

**Scenario Suggestions:**
1. Generate 3-4 recommended focal questions in scenario_suggestions.md
2. Base recommendations on:
   - Uncertainties flagged by multiple specialists
   - High-impact strategic choices for this company
   - Actionable time horizons
3. Present to user: "Pick one, provide your own, or ask me to refine these"

**Handoff:**
- User selects/provides focal question
- Offer refinement suggestions
- Proceed to Phase 1 (focal question documentation)

### If User Has Focal Question:
- Still ask 2-3 basic company questions
- Create minimal company.md
- Skip specialist discovery
- Generate 2-3 alternative focal questions based on basics only
- User confirms or refines
- Proceed to Phase 1
```

### 2. Specialist Prompts (`prompts/specialists/*.md`)

Add discovery mode instructions to each specialist:

```markdown
## Discovery Mode (Phase 0)

When invoked for company discovery:

1. **Read Context:** Review company.md to understand what we know
2. **Research:** Use pp-cli to research current conditions from your domain expertise
   - You decide what to research based on your professional judgment
   - Focus on trends, risks, opportunities, uncertainties relevant to this company
3. **Question Formulation:** Identify specific questions we should ask the user
4. **Document:** Create discovery transcript in conversations/[your_role]_discovery_roundN.md

**Discovery Transcript Format:**
- Research findings (with citations)
- Critical uncertainties from your perspective
- Specific questions for the user
- Preliminary assessment of strategic challenges

Trust your expertise - research what matters in your domain.
```

### 3. Metadata Tracking (`metadata.json`)

Add Phase 0 tracking:

```json
{
  "scenario_id": "SCENARIO-2025-XXX",
  "created_at": "2025-11-18T...",
  "status": "phase_0_discovery",
  "current_phase": 0,
  "phase_0": {
    "discovery_rounds": 2,
    "specialists_consulted": [
      {
        "specialist": "economist",
        "round": 1,
        "timestamp": "2025-11-18T...",
        "transcript": "conversations/economist_discovery_round1.md"
      },
      {
        "specialist": "geopolitician",
        "round": 1,
        "transcript": "conversations/geopolitician_discovery_round1.md"
      }
      // ... all 6 specialists, all rounds
    ],
    "convergence_reached": true,
    "user_confirmed": true,
    "scenario_suggestions_generated": true
  },
  "focal_question": "...",
  "phases": {
    "1": {"status": "pending"},
    "2": {"status": "pending"}
  }
}
```

### 4. File Organization

```
scenarios/active/SCENARIO-2025-XXX/
├── metadata.json
├── company.md (Phase 0 - living document)
├── phase_0_discovery/
│   ├── scenario_suggestions.md (Phase 0 output)
│   └── research/
│       ├── economist_discovery_round1.md
│       ├── economist_discovery_round2.md
│       ├── geopolitician_discovery_round1.md
│       ├── ecologist_discovery_round1.md
│       ├── futurist_discovery_round1.md
│       ├── anthropologist_discovery_round1.md
│       └── contrarian_discovery_round1.md
├── focal_question.md (Phase 1)
├── predetermined_elements.md (Phase 2)
└── ... (existing structure)
```

### 5. Template Files

Create new templates:
- `templates/company_profile.md` - Structure for company.md
- `templates/scenario_suggestions.md` - Structure for recommendations
- `templates/discovery_transcript.md` - Structure for specialist discovery output

---

## Architecture: Continuous vs. Fresh Context

**Dr. Wells: Continuous Context**
- She IS the main conversation (moderator)
- Runs continuously through entire discovery loop
- Maintains conversation memory of questions asked, answers received, findings
- Reads files (company.md, transcripts) to supplement memory
- Natural conversation flow with user

**Specialists: Fresh Context Each Round**
- Each discovery round, Wells invokes them fresh via Task tool
- They read company.md to get current state
- They read their own previous discovery transcript (if Round 2+)
- Create new transcript, exit
- Clean separation, no context bloat

**Advantage of Wells Continuous:**
- Natural conversational memory ("Last round you mentioned X...")
- Tracks convergence intuitively
- No re-orientation overhead

**Advantage of Specialists Fresh:**
- No context bloat from multiple rounds
- Clear file-based handoff (transcript)
- Can invoke different specialist combinations each round if needed

---

## Error Handling & Edge Cases

### Edge Case 1: User Provides Minimal Information
- User says "I don't know" or "not sure" to multiple questions
- **Wells' response:** "That's okay - let me have specialists research your industry broadly, then we can narrow down what's relevant to you"
- Proceed with generic industry research, refine as user learns

### Edge Case 2: Research Reveals Nothing Actionable
- Specialist researches but finds "stable industry, no major uncertainties"
- **Wells' response:** Still valuable - that specialist documents "From my perspective, this is a low-risk area"
- Other specialists may find uncertainties in their domains

### Edge Case 3: Convergence Never Reached
- After 3-4 rounds, still finding new uncertainties
- **Wells' judgment:** Set max rounds (e.g., 4), then force convergence
- Present to user: "We could keep discovering, but I have enough to generate scenarios. Should we proceed?"

### Edge Case 4: User Skips Discovery Then Lacks Context
- User says "I have a focal question" but provides vague question
- Phase 2+ specialists struggle without company context
- **Wells' response:** "I notice specialists are asking basic questions. Should we pause and do company discovery first?"
- Option to backfill Phase 0 mid-scenario

### Edge Case 5: pp-cli Research Fails
- Perplexity API error, rate limit, or no results
- **Specialist response:** Note in transcript: "Unable to research [topic] - proceeding with domain expertise only"
- Wells tracks: If multiple specialists hit failures, pause and notify user

### Error Handling: Transcript Validation
- If specialist returns <100 word transcript: Wells rejects, asks to elaborate
- If specialist returns no questions: Wells accepts (may indicate low-risk area from that perspective)
- If specialist doesn't cite research: Wells reminds to use pp-cli

### Performance Consideration
- 6 specialists per round = 6 sequential Task calls (can't parallelize Task tool)
- Round 1: ~10-15 minutes for all 6 specialists to research and respond
- **Wells manages expectations:** "I'm consulting all 6 specialists - this will take 10-15 minutes. I'll update you as each completes."

---

## Summary

**Phase 0 adds:**
1. Intelligent interview loop driven by specialist research findings
2. Comprehensive company profiling (company.md)
3. 6-perspective domain research (specialist discovery transcripts)
4. AI-generated scenario recommendations based on real market intelligence
5. Enriched context for all subsequent phases

**Impact:**
- Transforms system from "develop scenarios" to "discover + develop"
- Makes system accessible to users without pre-formed focal questions
- Grounds scenarios in real market conditions and current news
- Prevents specialists from re-asking basic questions in later phases
- Creates company-specific scenarios, not generic templates

**Next Steps:**
1. Create template files
2. Update moderator.md with Phase 0 instructions
3. Update all 6 specialist prompts with discovery mode
4. Update metadata schema
5. Test with example company (suggest using different industry than existing Synthyra example)
