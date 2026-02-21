# Research Provider Abstraction — Design Doc

**Date:** 2026-02-21
**Author:** Kirby (Remix Partners)
**Status:** Approved

## Problem

The Shell Scenario Panel currently hardcodes Perplexity (`pp-cli`) as its research tool across ~25 files. This creates two issues:

1. **Source quality** — Perplexity's sources are sometimes lower quality than desired for rigorous scenario planning.
2. **Lock-in** — Switching research providers requires editing every specialist prompt, the moderator prompt, hooks, templates, and docs.

## Goal

Replace Perplexity with a Claude + Gemini research stack while making the research layer **pluggable** so:
- The upstream project can accept the change (provider-agnostic)
- Future provider swaps are a config change, not a 25-file edit
- Existing Perplexity users aren't broken

## Architecture

### Two-Tier Research Model

| Tier | Use Case | Provider (Remix) | Provider (Default/Upstream) |
|------|----------|-------------------|-----------------------------|
| **Fast** | Quick fact-checks, current stats, recent events | Claude WebSearch (built-in) | Perplexity `pp` (existing) |
| **Deep** | Complex multi-source analysis, knowledge gap filling | Gemini Deep Research API | Perplexity `pp -r` (existing) |

### Provider Interface

All providers produce the same output format:

```json
{
  "query": "the search query",
  "answer": "Response with inline citations [1][2]",
  "citations": ["https://source1.com", "https://source2.com"],
  "provider": "gemini-deep-research",
  "confidence": "high|moderate|low"
}
```

### Configuration

In `.claude/config.json`:

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
        "args": ["--no-interactive", "--output", "json"]
      },
      "websearch": {
        "type": "builtin",
        "description": "Claude Code built-in WebSearch tool"
      },
      "gemini-deep-research": {
        "type": "script",
        "command": ".claude/lib/gemini-research.py",
        "model": "deep-research-pro-preview-12-2025",
        "timeout_minutes": 60
      }
    }
  }
}
```

## Components

### 1. Gemini Deep Research CLI Wrapper

**File:** `.claude/lib/gemini-research.py`

A Python script that:
- Takes a query string as argument
- Calls the Gemini Interactions API (`POST /v1beta/interactions`)
- Polls for completion (with progress reporting)
- Returns JSON in the standard provider format
- Handles errors (timeout, API key missing, quota exceeded)

**Dependencies:** `google-genai` Python package

**Usage:**
```bash
.claude/lib/gemini-research.py "complex multi-source analysis query"
```

**Output:**
```json
{
  "query": "complex multi-source analysis query",
  "answer": "Full research report with citations...",
  "citations": ["https://source1.com", ...],
  "provider": "gemini-deep-research",
  "confidence": "high",
  "duration_seconds": 342
}
```

**Error handling:**
- Missing API key → clear setup instructions in error message
- Timeout (>60 min) → report failure, suggest simpler query
- API error → include error details for debugging

### 2. Fast Tier (Claude WebSearch)

No new script needed. Domain specialists already run as Claude subagents with access to the WebSearch tool. The change is purely in their **prompt instructions**:

**Before:**
```bash
pp -r --no-interactive "US corporate debt to GDP 2025" --output json
```

**After:**
```
Use the WebSearch tool to look up current data when needed.
Include source URLs as citations in your transcript.
```

The expert query formulation guidance is preserved but reframed for natural language search queries rather than CLI commands.

### 3. Provider Documentation

**File:** `.claude/lib/research-providers.md`

Documents:
- Available providers and how to configure them
- Setup instructions for each provider
- Output format specification
- How to add new providers

## File Changes

### Modified Files (~15)

| File | Change |
|------|--------|
| `prompts/specialists/economist.md` | Replace `pp` commands with WebSearch guidance |
| `prompts/specialists/ecologist.md` | Replace `pp` commands with WebSearch guidance |
| `prompts/specialists/geopolitician.md` | Replace `pp` commands with WebSearch guidance |
| `prompts/specialists/anthropologist.md` | Replace `pp` commands with WebSearch guidance |
| `prompts/specialists/futurist.md` | Replace `pp` commands with WebSearch guidance |
| `prompts/specialists/contrarian.md` | Replace `pp` commands with WebSearch guidance |
| `prompts/specialists/researcher.md` | Replace `pp -r` with `gemini-research.py`; add timing guidance |
| `prompts/moderator.md` | Update research architecture description |
| `.claude/RESEARCH_INTEGRATION.md` | Rewrite for pluggable provider architecture |
| `.claude/config.json` | Add `research` provider configuration |
| `.claude/hooks/on-user-message.sh` | Update Phase 0b check (remove pp-cli reference) |
| `QUICKSTART.md` | Update prerequisites (Google AI key instead of pp-cli) |
| `README.md` | Update prerequisites section |
| `CLAUDE.md` | Update research tool references |

### New Files (2)

| File | Purpose |
|------|---------|
| `.claude/lib/gemini-research.py` | Gemini Deep Research CLI wrapper |
| `.claude/lib/research-providers.md` | Provider documentation |

## Backward Compatibility

Existing Perplexity users set:
```json
{
  "research": {
    "fast_provider": "perplexity",
    "deep_provider": "perplexity"
  }
}
```

Everything works exactly as before. The `pp-cli` command patterns remain documented as the Perplexity provider option.

## Upstream Contribution Strategy

This change can be contributed as a PR to the original project:
- **Framing:** "Make the research layer pluggable with provider abstraction"
- **Value:** Users can choose their preferred research tool
- **Default:** Perplexity remains the default (no breaking change)
- **New option:** Gemini Deep Research as an alternative provider

## Prerequisites for Remix Partners

1. **Google AI API key** (paid tier) from aistudio.google.com
2. **Python package:** `pip install google-genai`
3. **Environment variable:** `GEMINI_API_KEY` set in shell profile

## Timing Considerations

Gemini Deep Research takes 5-20 minutes per query (vs. seconds for Perplexity). This affects Dr. Anya Petrov's workflow:
- She is only invoked for gap-filling (not routine), so the delay is acceptable
- Her prompt should set expectations about wait times
- The wrapper script reports progress during polling
- A full scenario run's total time increases modestly since Anya is called infrequently

## Cost Estimate

- **Fast tier (Claude WebSearch):** Included in Claude subscription
- **Deep tier (Gemini Deep Research):** ~$2-5 per query
- **Typical scenario run:** 1-3 deep research queries = ~$5-15 total
- **Google AI API minimum:** Pay-as-you-go, no monthly minimum

## Success Criteria

1. Domain specialists can look up current data without pp-cli installed
2. Dr. Anya Petrov produces higher-quality research reports via Gemini Deep Research
3. Existing Perplexity users can continue using pp-cli with no changes
4. Provider can be swapped via config.json without editing prompts
5. All transcript, citation, and quality gate requirements still enforced
