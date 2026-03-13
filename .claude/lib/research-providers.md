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
