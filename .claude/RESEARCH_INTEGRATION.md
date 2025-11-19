# ABOUTME: Documentation of Perplexity AI research integration for Shell Scenario Panel
# Research Integration Architecture

## Overview

The Shell Scenario Panel now includes research capabilities through Perplexity AI integration, using a hybrid architecture where domain specialists can perform quick fact-checking while a dedicated research specialist handles complex multi-source analysis.

## Architecture Decision

**Test Result:** Sub-agents invoked via Task tool cannot themselves invoke Task tool (nested delegation not supported).

**Solution:** Hybrid approach combining direct tool access with gap-filling specialist.

## Implementation

### 1. Research Specialist (Dr. Anya Petrov)

**File:** `prompts/specialists/researcher.md`

**Role:** Gap-filling specialist for complex research needs

**Capabilities:**
- Multi-source data synthesis using pp-cli
- Contradiction resolution across sources
- Knowledge gap identification
- Confidence level assessment
- Current event and emerging trend analysis

**Invocation Pattern:**
```
Task("researcher", "SCENARIO: SCENARIO-2025-001

QUESTION: [Complex research question requiring multi-source synthesis]

TRANSCRIPT PATH: scenarios/active/SCENARIO-2025-001/conversations/researcher_transcript.md

Provide comprehensive analysis with citations and confidence levels.")
```

**When Dr. Wells invokes Anya:**
- Multiple specialists have contradictory factual assumptions
- Complex multi-source research required
- Knowledge gaps block scenario development
- Need synthesis across diverse data sources
- Fact-checking when specialists' knowledge is outdated

**When NOT to invoke:**
- Simple fact lookups (specialists handle these)
- Domain analysis questions
- Questions specialists can answer from expertise

### 2. Domain Specialist Direct Access

**Files Updated:**
- `prompts/specialists/economist.md` (example - pattern applies to all 6 domain specialists)

**Capability Added:**
Each domain specialist now has optional pp-cli access for quick fact-checking:

```bash
# Quick factual lookup
pp --no-interactive "query" --output json

# Parse results
RESULT=$(pp --no-interactive "US corporate debt to GDP 2025" --output json)
ANSWER=$(echo "$RESULT" | jq -r '.answer')
CITATIONS=$(echo "$RESULT" | jq -r '.citations[]')
```

**When specialists use pp-cli directly:**
- Verifying current statistics
- Checking recent policy changes
- Confirming recent events
- Quick fact validation

**In transcripts:**
- Log research conducted
- Include citations
- Note confidence levels

### 3. Moderator (Dr. Wells) Updates

**File:** `prompts/moderator.md`

**Changes:**
- Updated specialist count from 6 to 7
- Added Dr. Anya Petrov to team roster
- Added section "WHEN TO CONSULT DR. PETROV (RESEARCH SPECIALIST)"
- Clarified research architecture pattern

**Key guidance for Dr. Wells:**
- Domain specialists (1-6) have direct pp-cli access
- Dr. Petrov (7) is for gap-filling only
- Only invoke Petrov when knowledge gaps emerge that specialists cannot fill themselves

### 4. Project Documentation

**File:** `CLAUDE.md`

**Updates:**
- Specialist team expanded to 7 consultants
- Research architecture documented
- Clear separation: direct access vs. gap-filling specialist

## Research Tool: pp-cli (Perplexity AI)

**Quick Mode (Default):**
```bash
pp --no-interactive "query" --output json
```
- Fast, factual queries
- Model: sonar-pro
- Use for: statistics, current events, fact lookups

**Research Mode (Deep Analysis):**
```bash
pp -r --no-interactive "complex query" --output json
```
- Comprehensive synthesis
- Model: sonar-reasoning
- Use for: "Analyze...", "Compare...", "What are implications..."

**JSON Response Structure:**
```json
{
  "query": "search query",
  "answer": "Response with inline citations [1][2]",
  "citations": ["https://source1.com", "https://source2.com"],
  "model": "sonar-pro"
}
```

## Workflow Examples

### Example 1: Simple Fact Check (Specialist Direct)

```
Dr. Wells asks Sarah (economist): "Analyze debt constraints"

Sarah: "Let me verify current corporate debt levels..."
[Runs: pp --no-interactive "US corporate debt to GDP 2025" --output json]
Sarah: "At 47% of GDP [1], this indicates fragility-building phase because..."
[Returns analysis to Dr. Wells with citations]

Dr. Wells: [Synthesizes economist's analysis - never sees raw 47% number]
```

### Example 2: Knowledge Gap (Research Specialist)

```
Dr. Wells consults 3 specialists on AI regulation

Elena: "Regulation will constrain development"
Kenji: "Light-touch regulation will prevail"
Marcus: "Geopolitical competition will prevent coordination"

Dr. Wells: "Conflicting assumptions about regulation. Let me consult researcher..."

[Task("researcher", "Multi-source analysis of current AI regulation trends...")]

Anya: [Returns synthesis showing EU is strict, US is fragmented, China is strategic]

Dr. Wells: [Shares findings with specialists, identifies this as critical uncertainty]
```

## Key Principles

1. **Gap-Filling, Not Routine:** Research specialist is exception, not default
2. **Specialists Own Analysis:** Domain experts gather their own data and analyze
3. **Synthesis Not Relay:** Dr. Wells synthesizes insights, doesn't relay raw data
4. **Citations Required:** All research must include proper source attribution
5. **Confidence Levels:** Research findings note high/medium/low confidence
6. **Audit Trail:** All research logged in transcripts for verification

## Files Modified

- ✅ `prompts/specialists/researcher.md` (new - gap-filling research specialist)
- ✅ `prompts/specialists/economist.md` (research capabilities added)
- ✅ `prompts/specialists/ecologist.md` (research capabilities added)
- ✅ `prompts/specialists/geopolitic.md` (research capabilities added)
- ✅ `prompts/specialists/anthrpologist.md` (research capabilities added)
- ✅ `prompts/specialists/furutrist.md` (research capabilities added)
- ✅ `prompts/specialists/contrarian.md` (research capabilities added)
- ✅ `prompts/moderator.md` (specialist count, research guidance)
- ✅ `CLAUDE.md` (specialist team, architecture notes)
- ✅ `.claude/RESEARCH_INTEGRATION.md` (this file)

## Implementation Complete

All 6 domain specialists now have optional pp-cli access for quick fact-checking:
- Each specialist has domain-appropriate "When to use" examples
- Clear guidance on when to use research vs. domain expertise
- Transcript logging requirements for all research conducted
- Dr. Anya Petrov (research specialist) available for gap-filling when needed

## Testing Recommendations

1. **Specialist Direct Access Test:**
   - Run scenario requiring current statistics
   - Verify specialist uses pp-cli and includes citations
   - Check transcript logs research properly

2. **Research Specialist Gap-Filling Test:**
   - Create scenario where specialists have contradictory assumptions
   - Verify Dr. Wells identifies gap and invokes researcher
   - Check researcher provides multi-source synthesis
   - Confirm Dr. Wells synthesizes (not relays) findings

3. **Integration Test:**
   - Full scenario with both patterns
   - Verify appropriate tool selection at each phase
   - Check all transcripts include proper citations
   - Validate metadata tracks all research consultations

---

**Implementation Date:** 2025-11-12
**Architecture Pattern:** Hybrid (Direct Access + Gap-Filling Specialist)
**Nested Task Support:** No (tested and not supported)
**Primary Research Tool:** pp-cli (Perplexity AI API)
