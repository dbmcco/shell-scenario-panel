# Research Provider Abstraction — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace hardcoded Perplexity (pp-cli) research integration with a pluggable provider system using Claude WebSearch (fast tier) and Gemini Deep Research (deep tier).

**Architecture:** Two-tier research model — domain specialists use Claude's built-in WebSearch for quick fact-checks, Dr. Anya Petrov uses a Gemini Deep Research Python wrapper for deep analysis. Provider selection is config-driven so upstream users can keep using Perplexity.

**Tech Stack:** Python 3.14 (`google-genai` package), Bash, Claude Code tools (WebSearch, Task)

**Design doc:** `docs/plans/2026-02-21-research-provider-abstraction-design.md`

---

### Task 1: Create the Gemini Deep Research CLI Wrapper

**Files:**
- Create: `.claude/lib/gemini-research.py`

**Step 1: Write the script**

```python
#!/usr/bin/env python3
"""Gemini Deep Research CLI wrapper for Shell Scenario Panel.

Usage:
    gemini-research.py "your research query"
    gemini-research.py --timeout 30 "your research query"

Output: JSON with { query, answer, citations, provider, confidence, duration_seconds }

Requires:
    pip install google-genai
    export GEMINI_API_KEY=your-key
"""

import sys
import os
import json
import time
import argparse

def main():
    parser = argparse.ArgumentParser(description="Gemini Deep Research CLI")
    parser.add_argument("query", help="Research query string")
    parser.add_argument("--timeout", type=int, default=60,
                        help="Max wait time in minutes (default: 60)")
    args = parser.parse_args()

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print(json.dumps({
            "error": "GEMINI_API_KEY not set",
            "setup": "1. Get a paid API key from https://aistudio.google.com\n"
                     "2. Run: export GEMINI_API_KEY=your-key"
        }), file=sys.stderr)
        sys.exit(1)

    try:
        from google import genai
    except ImportError:
        print(json.dumps({
            "error": "google-genai not installed",
            "setup": "Run: pip install google-genai"
        }), file=sys.stderr)
        sys.exit(1)

    client = genai.Client(api_key=api_key)
    start_time = time.time()

    try:
        interaction = client.interactions.create(
            agent="deep-research-pro-preview-12-2025",
            input=args.query,
            background=True,
        )
    except Exception as e:
        print(json.dumps({
            "error": f"Failed to start research: {e}",
            "query": args.query
        }), file=sys.stderr)
        sys.exit(1)

    print(f"Research started (ID: {interaction.id}). Polling...",
          file=sys.stderr)

    deadline = start_time + (args.timeout * 60)
    while time.time() < deadline:
        interaction = client.interactions.get(interaction.id)
        if interaction.status == "completed":
            break
        if interaction.status == "failed":
            print(json.dumps({
                "error": f"Research failed: {getattr(interaction, 'error', 'unknown')}",
                "query": args.query,
                "provider": "gemini-deep-research"
            }), file=sys.stderr)
            sys.exit(1)
        elapsed = int(time.time() - start_time)
        print(f"  ...still researching ({elapsed}s elapsed)",
              file=sys.stderr)
        time.sleep(15)
    else:
        print(json.dumps({
            "error": f"Research timed out after {args.timeout} minutes",
            "query": args.query,
            "provider": "gemini-deep-research"
        }), file=sys.stderr)
        sys.exit(1)

    duration = int(time.time() - start_time)
    answer_text = interaction.outputs[-1].text if interaction.outputs else ""

    # Extract URLs from the answer text as citations (Gemini embeds them inline)
    import re
    urls = re.findall(r'https?://[^\s\)>\]]+', answer_text)
    citations = list(dict.fromkeys(urls))  # deduplicate, preserve order

    result = {
        "query": args.query,
        "answer": answer_text,
        "citations": citations,
        "provider": "gemini-deep-research",
        "confidence": "high",
        "duration_seconds": duration,
    }
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
```

**Step 2: Make it executable**

Run: `chmod +x /Users/remixpartners/Projects/shell-scenario-panel/.claude/lib/gemini-research.py`

**Step 3: Test the script runs (without API key)**

Run: `cd /Users/remixpartners/Projects/shell-scenario-panel && .claude/lib/gemini-research.py "test query" 2>&1`
Expected: Error message about GEMINI_API_KEY not set (confirms script runs)

**Step 4: Commit**

```bash
git add .claude/lib/gemini-research.py
git commit -m "feat: add Gemini Deep Research CLI wrapper

Provides a drop-in replacement for pp-cli research mode using
Google's Gemini Deep Research API. Returns JSON in the same
format as pp-cli for compatibility."
```

---

### Task 2: Add Research Provider Config to config.json

**Files:**
- Modify: `.claude/config.json`

**Step 1: Add the research config block**

Add after the `"specialists"` block (after line 147) in `.claude/config.json`:

```json
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
```

**Step 2: Verify JSON is valid**

Run: `cd /Users/remixpartners/Projects/shell-scenario-panel && python3 -c "import json; json.load(open('.claude/config.json')); print('Valid JSON')"`
Expected: "Valid JSON"

**Step 3: Commit**

```bash
git add .claude/config.json
git commit -m "feat: add pluggable research provider config

Supports three providers: perplexity (original), websearch (Claude
built-in), and gemini-deep-research. Provider selection is
config-driven to support upstream contribution."
```

---

### Task 3: Update Domain Specialist Prompts (6 files)

**Files:**
- Modify: `prompts/specialists/economist.md` (lines 194-307)
- Modify: `prompts/specialists/ecologist.md` (same pattern)
- Modify: `prompts/specialists/geopolitician.md` (same pattern)
- Modify: `prompts/specialists/anthropologist.md` (same pattern)
- Modify: `prompts/specialists/futurist.md` (same pattern)
- Modify: `prompts/specialists/contrarian.md` (same pattern, plus lines 28-65 discovery section)

Each specialist has two sections to update:

**Section A: `## RESEARCH CAPABILITIES (OPTIONAL)`**

Replace the pp-cli instructions with:

```markdown
## RESEARCH CAPABILITIES (OPTIONAL)

When you need current data beyond your knowledge cutoff, use the **WebSearch tool** to look up information:

**When to use:**
- Verifying current statistics relevant to your domain
- Checking recent policy changes or announcements
- Confirming recent events

**When NOT to use:**
- For structural analysis (use your expertise)
- For theoretical frameworks (you already know these)
- For historical patterns (part of your knowledge)

**In your transcript:**
- Log what research you conducted
- Include source URLs as citations: "According to [source], ..."
- Note confidence levels if data conflicts

**Note:** For complex multi-source research needs, Dr. Wells may consult the research specialist (Dr. Petrov). You focus on your domain analysis; research is supplementary.
```

**Section B: `### Formulating Expert Queries (IMPORTANT)`**

Replace the pp-cli query guidance with:

```markdown
### Formulating Expert Queries (IMPORTANT)

**Your query language determines result quality.** Use expert terminology to get sophisticated results.

❌ **Generic queries (get generic results):**
"corporate debt levels 2025"

✅ **Expert queries (get sophisticated results):**
"sectoral balance sheet dynamics non-financial corporate leverage ratios maturity mismatches Q2 2025"

**Query formulation principles:**
1. **Use your technical vocabulary** - domain-specific terms and frameworks
2. **Reference theoretical frameworks** - named theories and models
3. **Specify precise concepts** - don't use vague language
4. **Include measurement specifics** - ratios, indicators, time periods
5. **Signal analytical depth** - use precise language, not casual summaries
```

(Each specialist keeps their own domain-specific query examples — just remove the `pp -r --no-interactive "..." --output json` wrapping and present them as plain search queries.)

**Section C: `### CRITICAL: Evaluate Search Results Through Your Expert Lens`**

This section stays nearly identical — just remove references to "Perplexity" and "pp-cli". The critical evaluation guidance is excellent and tool-agnostic.

**For contrarian.md specifically**, also update the discovery section (lines 28-65):
- Line 28: Change "Conduct research using pp-cli" → "Conduct research using the WebSearch tool"
- Line 54: Change "with pp-cli citations" → "with source citations"
- Lines 59-63: Replace `pp -r` example commands with plain search query examples

**Step 1: Update economist.md**

(Modify as described above)

**Step 2: Update ecologist.md**

(Same pattern)

**Step 3: Update geopolitician.md**

(Same pattern)

**Step 4: Update anthropologist.md**

(Same pattern)

**Step 5: Update futurist.md**

(Same pattern)

**Step 6: Update contrarian.md**

(Same pattern, plus discovery section)

**Step 7: Verify no pp-cli references remain in specialist files**

Run: `grep -r "pp-cli\|pp -r\|pp --no-interactive\|perplexity" /Users/remixpartners/Projects/shell-scenario-panel/prompts/specialists/ --include="*.md" -l`
Expected: Only `researcher.md` should match (updated in Task 4)

**Step 8: Commit**

```bash
git add prompts/specialists/economist.md prompts/specialists/ecologist.md \
        prompts/specialists/geopolitician.md prompts/specialists/anthropologist.md \
        prompts/specialists/futurist.md prompts/specialists/contrarian.md
git commit -m "feat: switch domain specialists from pp-cli to WebSearch

Replace Perplexity pp-cli instructions with Claude WebSearch tool
guidance in all 6 domain specialist prompts. Expert query
formulation guidance preserved. Critical evaluation guidance
unchanged."
```

---

### Task 4: Update Research Specialist (Dr. Anya Petrov)

**Files:**
- Modify: `prompts/specialists/researcher.md`

**Step 1: Replace the research tool section (lines 116-204)**

Replace `## RESEARCH TOOL: PERPLEXITY AI` with:

```markdown
## RESEARCH TOOL: GEMINI DEEP RESEARCH

**IMPORTANT: Use the Gemini Deep Research script for ALL research. Do NOT use WebSearch or other tools — your role requires comprehensive, multi-source analysis.**

You have access to Gemini Deep Research for thorough, multi-source analysis:

### Running Research
```bash
.claude/lib/gemini-research.py "complex query requiring synthesis"
```

**Important:** Deep research takes 5-20 minutes per query. This is expected — the tool conducts 80-160 web searches and produces a comprehensive research report. Plan your queries carefully to minimize the number needed.

### Parsing Results
```bash
RESULT=$(.claude/lib/gemini-research.py "query")
ANSWER=$(echo "$RESULT" | jq -r '.answer')
CITATIONS=$(echo "$RESULT" | jq -r '.citations[]')
```

### Response Format
The tool returns JSON:
```json
{
  "query": "your search query",
  "answer": "Comprehensive research report with citations...",
  "citations": ["https://source1.com", "https://source2.com"],
  "provider": "gemini-deep-research",
  "confidence": "high",
  "duration_seconds": 342
}
```

**Use deep research for all queries.** Your role is comprehensive multi-source analysis, not quick lookups.
```

**Step 2: Update query formulation section**

Replace "pp-cli queries go to Perplexity, which is LLM-based" with:
"Your query is sent to Gemini Deep Research, which conducts extensive web research. Your query language determines what sources it prioritizes."

Remove all `pp -r --no-interactive "..." --output json` wrapping around example queries — present them as plain query strings passed to the script.

**Step 3: Update output format section (lines 316-349)**

Replace `pp -r --no-interactive "query" --output json` with `.claude/lib/gemini-research.py "query"`.

**Step 4: Verify no pp-cli references remain**

Run: `grep -c "pp-cli\|pp -r\|pp --no-interactive" /Users/remixpartners/Projects/shell-scenario-panel/prompts/specialists/researcher.md`
Expected: 0

**Step 5: Commit**

```bash
git add prompts/specialists/researcher.md
git commit -m "feat: switch research specialist from pp-cli to Gemini Deep Research

Dr. Anya Petrov now uses Gemini Deep Research for comprehensive
multi-source analysis. Expert query formulation and critical
evaluation guidance preserved."
```

---

### Task 5: Update Moderator Prompt (Dr. Wells)

**Files:**
- Modify: `prompts/moderator.md`

**Step 1: Update Phase 0b instructions (around line 100-105)**

Replace:
```bash
pp -r --no-interactive "your research query here" --output json
```
With:
```
Use the WebSearch tool for targeted searches, or consult Dr. Petrov for comprehensive research.
```

**Step 2: Update discovery section (around line 175-186)**

Replace:
- "using pp-cli research mode" → "using the WebSearch tool"
- "Use pp-cli with this syntax:" + pp-cli code block → "Use the WebSearch tool to look up current data relevant to your domain."
- Example `pp -r` command → plain search query example

**Step 3: Update transcript validation (around line 207)**

Replace "with pp-cli citations where applicable" → "with source citations where applicable"

**Step 4: Update error handling (around line 444-451)**

Replace:
- "pp-cli research fails" → "Research tool fails"
- "Remind to use pp-cli for research" → "Remind to use WebSearch for research"

**Step 5: Update monitoring section (around line 1322)**

Replace "use `pp -r`" → "use the WebSearch tool or consult Dr. Petrov"

**Step 6: Update Dr. Petrov invocation guidance (around line 1378)**

Replace "specialists can use pp-cli research mode directly" → "specialists can use WebSearch directly"

**Step 7: Verify no pp-cli references remain**

Run: `grep -c "pp-cli\|pp -r\|pp --no-interactive" /Users/remixpartners/Projects/shell-scenario-panel/prompts/moderator.md`
Expected: 0

**Step 8: Commit**

```bash
git add prompts/moderator.md
git commit -m "feat: update moderator to use WebSearch and Gemini Deep Research

Replace pp-cli references with WebSearch (domain specialists)
and Gemini Deep Research (research specialist) throughout
Dr. Wells' moderator instructions."
```

---

### Task 6: Update the Hook Script

**Files:**
- Modify: `.claude/hooks/on-user-message.sh` (lines 122-125)

**Step 1: Update Phase 0b check**

Replace lines 122-125:
```bash
        if [ ! -f "$context_packet" ]; then
            warnings="${warnings}- Phase 0b context enrichment packet missing (pp -r search).\n"
        elif grep -q "\\[gap\\]" "$context_packet"; then
            warnings="${warnings}- Phase 0b context enrichment packet not completed (pp -r search).\n"
        fi
```

With:
```bash
        if [ ! -f "$context_packet" ]; then
            warnings="${warnings}- Phase 0b context enrichment packet missing (research needed).\n"
        elif grep -q "\\[gap\\]" "$context_packet"; then
            warnings="${warnings}- Phase 0b context enrichment packet not completed (research needed).\n"
        fi
```

**Step 2: Commit**

```bash
git add .claude/hooks/on-user-message.sh
git commit -m "fix: remove pp-cli reference from Phase 0b hook warning"
```

---

### Task 7: Rewrite RESEARCH_INTEGRATION.md

**Files:**
- Modify: `.claude/RESEARCH_INTEGRATION.md`

**Step 1: Rewrite the file**

Replace the entire contents with updated documentation describing:

- The pluggable provider architecture
- Two-tier model (fast: WebSearch, deep: Gemini Deep Research)
- Config-driven provider selection
- How to switch back to Perplexity
- JSON output format specification
- Workflow examples updated for new tools
- File list of all modified files

Keep the same structure and level of detail as the current file — it serves as important architecture documentation.

**Step 2: Commit**

```bash
git add .claude/RESEARCH_INTEGRATION.md
git commit -m "docs: rewrite research integration for pluggable provider architecture"
```

---

### Task 8: Update QUICKSTART.md and README.md

**Files:**
- Modify: `QUICKSTART.md` (lines 7-11)
- Modify: `README.md` (lines 44-49)
- Modify: `CLAUDE.md` (research references)

**Step 1: Update QUICKSTART.md prerequisites**

Replace lines 7-11:
```markdown
**Install pp-cli:**
```bash
npm install -g @dbmcco/pp-cli
pp --version
```
```

With:
```markdown
**Research tool setup (choose one):**

**Option A: Gemini Deep Research (recommended)**
```bash
pip install google-genai
export GEMINI_API_KEY=your-key-from-aistudio.google.com
```

**Option B: Perplexity (original)**
```bash
npm install -g @dbmcco/pp-cli
pp config  # enter API key
```

**Option C: Claude WebSearch only (no deep research)**
No setup needed — WebSearch is built into Claude Code.
```

**Step 2: Update README.md prerequisites**

Replace lines 44-49 (the `Required: Perplexity CLI` section) with the same three-option format.

**Step 3: Update CLAUDE.md research references**

Search for and update any references to pp-cli or Perplexity in the project CLAUDE.md. Replace with provider-agnostic language or mention the new two-tier model.

**Step 4: Commit**

```bash
git add QUICKSTART.md README.md CLAUDE.md
git commit -m "docs: update prerequisites for pluggable research providers

Users can now choose between Gemini Deep Research (recommended),
Perplexity (original), or Claude WebSearch only."
```

---

### Task 9: Create Provider Documentation

**Files:**
- Create: `.claude/lib/research-providers.md`

**Step 1: Write the provider docs**

```markdown
# Research Providers

The Shell Scenario Panel supports pluggable research providers configured via `.claude/config.json`.

## Available Providers

### websearch (Claude Built-in)
- **Type:** Built-in Claude Code tool
- **Speed:** Fast (seconds)
- **Depth:** Standard web search
- **Cost:** Included with Claude subscription
- **Setup:** None required
- **Best for:** Quick fact-checks, current statistics, recent events

### gemini-deep-research
- **Type:** Python script (`.claude/lib/gemini-research.py`)
- **Speed:** Slow (5-20 minutes per query)
- **Depth:** Comprehensive — 80-160 web searches, full research report
- **Cost:** ~$2-5 per query (Google AI pay-as-you-go)
- **Setup:** `pip install google-genai` + `export GEMINI_API_KEY=your-key`
- **Best for:** Complex multi-source analysis, knowledge gap filling

### perplexity
- **Type:** CLI tool (`pp-cli`)
- **Speed:** Fast (seconds)
- **Depth:** Moderate — LLM-synthesized search results
- **Cost:** Perplexity API subscription
- **Setup:** `npm install -g @dbmcco/pp-cli` + `pp config`
- **Best for:** Quick to moderate research queries

## Configuration

In `.claude/config.json`, set:

```json
{
  "research": {
    "fast_provider": "websearch",
    "deep_provider": "gemini-deep-research"
  }
}
```

### Recommended Configurations

| Use Case | fast_provider | deep_provider |
|----------|---------------|---------------|
| Claude + Gemini (recommended) | websearch | gemini-deep-research |
| Perplexity only (original) | perplexity | perplexity |
| No deep research | websearch | websearch |

## Output Format

All providers return JSON:

```json
{
  "query": "the search query",
  "answer": "Response with inline citations",
  "citations": ["https://source1.com"],
  "provider": "provider-name",
  "confidence": "high|moderate|low"
}
```

## Adding a New Provider

1. Create a CLI wrapper that accepts a query and returns the JSON format above
2. Add the provider to `config.json` under `research.providers`
3. Set it as `fast_provider` or `deep_provider`
```

**Step 2: Commit**

```bash
git add .claude/lib/research-providers.md
git commit -m "docs: add research provider documentation"
```

---

### Task 10: Verify All Changes and Final Commit

**Step 1: Verify no pp-cli references remain in active code**

Run: `grep -r "pp-cli\|pp -r\|pp --no-interactive" /Users/remixpartners/Projects/shell-scenario-panel/ --include="*.md" --include="*.sh" --include="*.json" -l | grep -v "research-providers.md" | grep -v "docs/plans/" | grep -v "docs/testing/" | grep -v "RESEARCH_FINDINGS.md" | grep -v "workflow-visualization/"`
Expected: No results (only historical/documentation files should remain)

**Step 2: Verify config.json is valid**

Run: `python3 -c "import json; json.load(open('/Users/remixpartners/Projects/shell-scenario-panel/.claude/config.json')); print('Valid')"`
Expected: "Valid"

**Step 3: Verify gemini-research.py runs**

Run: `cd /Users/remixpartners/Projects/shell-scenario-panel && .claude/lib/gemini-research.py "test" 2>&1 | head -5`
Expected: Error about GEMINI_API_KEY (confirms script is executable and importable)

**Step 4: Final summary commit (if any stragglers)**

```bash
git add -A
git status
# Only commit if there are remaining changes
git commit -m "chore: final cleanup for research provider abstraction"
```
