#!/usr/bin/env python3
"""Gemini Deep Research CLI wrapper for Shell Scenario Panel.

Calls Google's Gemini Deep Research API via the Interactions endpoint,
polls for completion, and returns a JSON result compatible with the
shell-scenario-panel provider interface.

Usage:
    gemini-research.py "your research query"
    gemini-research.py --timeout 30 "your research query"

Output (stdout): JSON with { query, answer, citations, provider, confidence, duration_seconds }
Progress (stderr): Polling status and error messages

Requires:
    pip install google-genai
    export GEMINI_API_KEY=your-key-from-aistudio.google.com
"""

import sys
import os
import json
import re
import time
import argparse


def eprint(*args, **kwargs):
    """Print to stderr so stdout stays clean for JSON output."""
    print(*args, file=sys.stderr, **kwargs)


def extract_citations(outputs):
    """Extract citation URLs from interaction outputs.

    Tries two strategies:
    1. Structured annotations on text outputs (preferred, includes start/end indices)
    2. Regex extraction of URLs from the answer text (fallback)

    Returns a deduplicated list of URLs preserving first-seen order.
    """
    urls = []

    # Strategy 1: Check for structured annotations on output parts
    for output in outputs:
        annotations = getattr(output, "annotations", None)
        if annotations:
            for annotation in annotations:
                source = getattr(annotation, "source", None)
                if source:
                    # source may be a string URL or an object with a url attribute
                    url = getattr(source, "url", None) or (
                        source if isinstance(source, str) and source.startswith("http") else None
                    )
                    if url:
                        urls.append(url)

    # Strategy 2: Regex fallback — extract URLs from the text itself
    answer_text = ""
    for output in outputs:
        text = getattr(output, "text", None)
        if text:
            answer_text += text

    if answer_text:
        # Match http/https URLs, stopping at whitespace, closing parens/brackets,
        # angle brackets, or common markdown punctuation that follows URLs
        inline_urls = re.findall(r'https?://[^\s\)>\]\'"]+', answer_text)
        # Strip trailing punctuation that may have been captured
        cleaned = []
        for u in inline_urls:
            u = u.rstrip(".,;:!?")
            if u:
                cleaned.append(u)
        urls.extend(cleaned)

    # Deduplicate while preserving order
    seen = set()
    unique = []
    for url in urls:
        if url not in seen:
            seen.add(url)
            unique.append(url)

    return unique


def get_answer_text(outputs):
    """Extract the final answer text from interaction outputs.

    Deep Research typically produces multiple outputs during its run
    (research plan, intermediate findings, final report). The last
    text output is the completed report.
    """
    for output in reversed(outputs):
        text = getattr(output, "text", None)
        if text:
            return text
    return ""


def main():
    parser = argparse.ArgumentParser(
        description="Run a query through Google's Gemini Deep Research agent.",
        epilog=(
            "Examples:\n"
            '  %(prog)s "History and future of nuclear fusion energy"\n'
            '  %(prog)s --timeout 30 "Compare EV battery chemistries"\n'
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("query", help="Research query string")
    parser.add_argument(
        "--timeout",
        type=int,
        default=60,
        help="Maximum wait time in minutes (default: 60)",
    )
    args = parser.parse_args()

    # --- Validate API key ---
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        eprint(
            "Error: GEMINI_API_KEY environment variable is not set.\n"
            "\n"
            "To set up Gemini Deep Research:\n"
            "  1. Get an API key from https://aistudio.google.com\n"
            "  2. Add to your shell profile:\n"
            "       export GEMINI_API_KEY=your-key-here\n"
            "  3. Restart your terminal or run the export command\n"
        )
        sys.exit(1)

    # --- Import google-genai (deferred so missing-key error is cleaner) ---
    try:
        from google import genai
    except ImportError:
        eprint(
            "Error: The google-genai package is not installed.\n"
            "\n"
            "Install it with:\n"
            "  pip install google-genai\n"
            "\n"
            "Requires version 1.55.0 or later for Interactions API support.\n"
        )
        sys.exit(1)

    # --- Start Deep Research ---
    client = genai.Client(api_key=api_key)
    start_time = time.time()

    eprint(f"Starting Gemini Deep Research...")
    eprint(f"  Query: {args.query[:120]}{'...' if len(args.query) > 120 else ''}")
    eprint(f"  Timeout: {args.timeout} minutes")

    try:
        interaction = client.interactions.create(
            agent="deep-research-pro-preview-12-2025",
            input=args.query,
            background=True,
        )
    except Exception as exc:
        eprint(f"Error: Failed to start research.\n  {exc}")
        sys.exit(1)

    eprint(f"  Interaction ID: {interaction.id}")
    eprint(f"  Polling every 15 seconds...")

    # --- Poll for completion ---
    deadline = start_time + (args.timeout * 60)
    poll_count = 0

    while time.time() < deadline:
        try:
            interaction = client.interactions.get(interaction.id)
        except Exception as exc:
            eprint(f"  Warning: polling error (will retry): {exc}")
            time.sleep(15)
            continue

        status = getattr(interaction, "status", "unknown")

        if status == "completed":
            break

        if status in ("failed", "cancelled"):
            error_detail = getattr(interaction, "error", "no details available")
            eprint(f"Error: Research {status}.\n  {error_detail}")
            sys.exit(1)

        poll_count += 1
        elapsed = int(time.time() - start_time)
        minutes = elapsed // 60
        seconds = elapsed % 60
        eprint(f"  [{minutes:02d}:{seconds:02d}] Status: {status} (poll #{poll_count})")
        time.sleep(15)
    else:
        # while/else: the loop ended because the deadline was exceeded
        eprint(
            f"Error: Research timed out after {args.timeout} minutes.\n"
            "  The query may be too broad. Try:\n"
            "  - A more specific query\n"
            "  - Increasing --timeout\n"
        )
        sys.exit(1)

    # --- Extract results ---
    duration = int(time.time() - start_time)
    outputs = interaction.outputs if interaction.outputs else []

    answer_text = get_answer_text(outputs)
    citations = extract_citations(outputs)

    if not answer_text:
        eprint("Warning: Research completed but no answer text was found in outputs.")

    eprint(f"  Research completed in {duration} seconds.")
    eprint(f"  Answer length: {len(answer_text)} characters")
    eprint(f"  Citations found: {len(citations)}")

    # --- Output JSON to stdout ---
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
