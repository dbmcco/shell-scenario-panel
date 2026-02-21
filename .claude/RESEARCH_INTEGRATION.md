# ABOUTME: Documentation of pluggable research provider architecture for Shell Scenario Panel
# Research Integration Architecture

## Overview

The Shell Scenario Panel uses a **pluggable research provider architecture** with a two-tier model. Providers are configured in `.claude/config.json` and can be swapped without changing specialist prompts or moderator logic.

**Two tiers:**
- **Fast tier** (domain specialists): Claude Code built-in `WebSearch` tool for quick fact-checks and current data lookups
- **Deep tier** (Dr. Anya Petrov): Gemini Deep Research via `.claude/lib/gemini-research.py` for comprehensive multi-source analysis

This replaces the earlier single-tool architecture (pp-cli / Perplexity AI) with a flexible provider system that separates quick lookups from deep research.

## Provider Configuration

Research providers are declared in the `research` block of `.claude/config.json`:

```json
{
  "research": {
    "fast_provider": "websearch",
    "deep_provider": "gemini-deep-research",
    "gemini_api_key_env": "GEMINI_API_KEY",
    "providers": {
      "perplexity": {
        "type": "cli",
        "command": "pp",
        "research_flag": "-r",
        "args": ["--no-interactive", "--output", "json"],
        "description": "Perplexity AI via pp-cli (original default)"
      },
      "websearch": {
        "type": "builtin",
        "description": "Claude Code built-in WebSearch tool for quick fact-checks"
      },
      "gemini-deep-research": {
        "type": "script",
        "command": ".claude/lib/gemini-research.py",
        "model": "deep-research-pro-preview-12-2025",
        "timeout_minutes": 60,
        "description": "Google Gemini Deep Research for comprehensive multi-source analysis"
      }
    }
  }
}
```

### Provider Options

| Provider | Type | Tier | Description |
|----------|------|------|-------------|
| `websearch` | `builtin` | Fast | Claude Code's built-in `WebSearch` tool. Zero configuration, always available. Used by domain specialists for quick fact-checks. |
| `gemini-deep-research` | `script` | Deep | Google Gemini Deep Research via `.claude/lib/gemini-research.py`. Runs multi-step background research with polling. Requires `GEMINI_API_KEY` environment variable. |
| `perplexity` | `cli` | Fast or Deep | Perplexity AI via `pp-cli`. Original default provider. Requires Perplexity API key configured via `pp config`. Available as a fallback. |

The `fast_provider` and `deep_provider` keys control which providers are active. Change these values to swap providers without modifying any specialist or moderator prompts.

## Implementation

### 1. Research Specialist (Dr. Anya Petrov)

**File:** `prompts/specialists/researcher.md`

**Role:** Gap-filling specialist for complex research needs

**Primary Tool:** Gemini Deep Research (`.claude/lib/gemini-research.py`)

**Capabilities:**
- Multi-source data synthesis using Gemini Deep Research
- Contradiction resolution across sources
- Knowledge gap identification
- Confidence level assessment
- Current event and emerging trend analysis
- Comprehensive reports with inline citations

**Invocation Pattern (unchanged):**
```
Task("researcher", "SCENARIO: SCENARIO-2025-001

QUESTION: [Complex research question requiring multi-source synthesis]

TRANSCRIPT PATH: scenarios/active/SCENARIO-2025-001/conversations/researcher_transcript.md

Provide comprehensive analysis with citations and confidence levels.")
```

**How Anya uses Gemini Deep Research:**
```bash
python3 .claude/lib/gemini-research.py "your research query"
# Progress messages go to stderr
# JSON result goes to stdout
```

The script polls the Gemini Interactions API, handles timeouts (default 60 minutes), and returns results in the standard provider JSON format.

**When Dr. Wells invokes Anya:**
- Multiple specialists have contradictory factual assumptions
- Complex multi-source research required
- Knowledge gaps block scenario development
- Need synthesis across diverse data sources
- Fact-checking when specialists' knowledge is outdated

**When NOT to invoke:**
- Simple fact lookups (specialists handle these via WebSearch)
- Domain analysis questions
- Questions specialists can answer from expertise

### 2. Domain Specialist Direct Access

**Files Updated:**
- `prompts/specialists/economist.md` (example - pattern applies to all 6 domain specialists)

**Capability:** Each domain specialist now uses the Claude Code built-in `WebSearch` tool for quick fact-checking.

**Usage pattern:**
```
WebSearch("US corporate debt to GDP ratio 2026")
```

WebSearch returns search results with URLs and snippets. Specialists extract the relevant facts, cite the sources, and continue their analysis.

**When specialists use WebSearch directly:**
- Verifying current statistics
- Checking recent policy changes
- Confirming recent events
- Quick fact validation

**When NOT to use WebSearch:**
- Complex multi-source synthesis (escalate to Dr. Petrov)
- Questions requiring contradiction resolution across many sources
- Deep background research on emerging trends

**In transcripts:**
- Log research conducted
- Include citations from search results
- Note confidence levels

### 3. Moderator (Dr. Wells) Updates

**File:** `prompts/moderator.md`

**Changes:**
- Research architecture section updated to reflect two-tier provider model
- Domain specialists (1-6) now use WebSearch instead of pp-cli
- Dr. Petrov (7) uses Gemini Deep Research for gap-filling
- Clarified when each tier is appropriate

**Key guidance for Dr. Wells:**
- Domain specialists (1-6) have direct WebSearch access for quick lookups
- Dr. Petrov (7) uses Gemini Deep Research for comprehensive analysis
- Only invoke Petrov when knowledge gaps emerge that specialists cannot fill themselves

### 4. Project Documentation

**File:** `CLAUDE.md`

**Updates:**
- Specialist team remains 7 consultants
- Research architecture updated to two-tier provider model
- Clear separation: WebSearch (fast) vs. Gemini Deep Research (deep)

## JSON Output Format

All providers share a common JSON output format for interoperability:

```json
{
  "query": "search query",
  "answer": "Response with inline citations [1][2]",
  "citations": ["https://source1.com", "https://source2.com"],
  "provider": "provider-name",
  "confidence": "high"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `query` | string | The original search query |
| `answer` | string | Response text with inline citation markers `[1][2]` |
| `citations` | array | List of source URLs, ordered by citation number |
| `provider` | string | Provider identifier (`websearch`, `gemini-deep-research`, `perplexity`) |
| `confidence` | string | `high`, `medium`, or `low` confidence assessment |

The Gemini Deep Research provider adds an additional `duration_seconds` field tracking how long the research took.

WebSearch results are converted to this format by the specialist during synthesis (WebSearch itself returns search result blocks, not this JSON directly).

## Workflow Examples

### Example 1: Simple Fact Check (Specialist Direct via WebSearch)

```
Dr. Wells asks Sarah (economist): "Analyze debt constraints"

Sarah: "Let me verify current corporate debt levels..."
[Uses WebSearch("US corporate debt to GDP ratio 2026")]
Sarah: "At 48% of GDP [1], this indicates fragility-building phase because..."
[Returns analysis to Dr. Wells with citations from search results]

Dr. Wells: [Synthesizes economist's analysis - never sees raw 48% number]
```

### Example 2: Knowledge Gap (Research Specialist via Gemini Deep Research)

```
Dr. Wells consults 3 specialists on AI regulation

Elena: "Regulation will constrain development"
Kenji: "Light-touch regulation will prevail"
Marcus: "Geopolitical competition will prevent coordination"

Dr. Wells: "Conflicting assumptions about regulation. Let me consult researcher..."

[Task("researcher", "Multi-source analysis of current AI regulation trends...")]

Anya: [Runs gemini-research.py, returns comprehensive synthesis showing
       EU is strict, US is fragmented, China is strategic, with 15+ citations]

Dr. Wells: [Shares findings with specialists, identifies this as critical uncertainty]
```

## Key Principles

1. **Gap-Filling, Not Routine:** Research specialist is exception, not default
2. **Specialists Own Analysis:** Domain experts gather their own data and analyze
3. **Synthesis Not Relay:** Dr. Wells synthesizes insights, doesn't relay raw data
4. **Citations Required:** All research must include proper source attribution
5. **Confidence Levels:** Research findings note high/moderate/low confidence
6. **Audit Trail:** All research logged in transcripts for verification

## Files Modified

- `prompts/specialists/researcher.md` (updated to use Gemini Deep Research)
- `prompts/specialists/economist.md` (WebSearch replaces pp-cli)
- `prompts/specialists/ecologist.md` (WebSearch replaces pp-cli)
- `prompts/specialists/geopolitician.md` (WebSearch replaces pp-cli)
- `prompts/specialists/anthropologist.md` (WebSearch replaces pp-cli)
- `prompts/specialists/futurist.md` (WebSearch replaces pp-cli)
- `prompts/specialists/contrarian.md` (WebSearch replaces pp-cli)
- `prompts/moderator.md` (research architecture updated to two-tier model)
- `CLAUDE.md` (research architecture notes updated)
- `.claude/config.json` (new `research` block with provider definitions)
- `.claude/lib/gemini-research.py` (new - Gemini Deep Research CLI wrapper)
- `.claude/RESEARCH_INTEGRATION.md` (this file - rewritten for new architecture)

## Backward Compatibility

The Perplexity provider (`pp-cli`) remains configured in `.claude/config.json` and can be reactivated by changing the `fast_provider` and/or `deep_provider` values:

```json
{
  "research": {
    "fast_provider": "perplexity",
    "deep_provider": "perplexity"
  }
}
```

This restores the original single-provider behavior. Specialist prompts reference the configured provider, so no prompt changes are needed when switching.

**Note:** Perplexity requires an API key. Run `pp config` to set it up if switching back.

## Testing Recommendations

1. **WebSearch Direct Access Test:**
   - Run scenario requiring current statistics
   - Verify specialist uses WebSearch and includes citations
   - Check transcript logs research properly

2. **Gemini Deep Research Gap-Filling Test:**
   - Create scenario where specialists have contradictory assumptions
   - Verify Dr. Wells identifies gap and invokes researcher
   - Check researcher runs `gemini-research.py` and returns multi-source synthesis
   - Confirm Dr. Wells synthesizes (not relays) findings

3. **Integration Test:**
   - Full scenario with both tiers active
   - Verify appropriate tool selection at each phase (WebSearch for quick lookups, Gemini for deep research)
   - Check all transcripts include proper citations
   - Validate metadata tracks all research consultations

4. **Provider Swap Test:**
   - Change `fast_provider` to `perplexity` in config.json
   - Verify specialists correctly use pp-cli instead of WebSearch
   - Change back and confirm WebSearch resumes

---

**Implementation Date:** 2026-02-21
**Architecture Pattern:** Pluggable Provider (Fast + Deep tiers)
**Primary Research Tools:** WebSearch (fast) + Gemini Deep Research (deep)
**Fallback Provider:** Perplexity AI via pp-cli (configurable)
