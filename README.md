# Shell Scenario Panel

A Claude Code-powered Shell-style scenario planning system with multi-specialist consultation and rigorous documentation enforcement.

## Overview

This is a structured scenario planning tool based on the Shell methodology, featuring:
- **Dr. Michelle Wells** (Moderator) - Facilitates 7-phase scenario development process
- **6 Domain Specialist Consultants** - Diverse expert perspectives (ecology, geopolitics, culture, technology, economics, contrarian)
- **Dr. Anya Petrov** (Research Specialist) - Multi-source research and fact-checking
- **Dr. Mei Chen** (Quality Analyst) - Automated quality gates prevent regression to generic analysis
- **Intelligent Company Discovery** - AI-guided interview loop with specialist research
- **Resources-First Intake** - Drop materials into `resources/` for automatic indexing
- **Automated Quality Enforcement** - Hooks trigger quality gates, ensure intellectual integrity
- **DraftForge-inspired Architecture** - Proven patterns for multi-agent coordination

## Quick Start

### 1. Clone and Start Claude Code

```bash
git clone https://github.com/dbmcco/shell-scenario-panel.git
cd shell-scenario-panel
# Start Claude Code conversation
```

### 2. Tell Dr. Wells What You Want to Explore

Just describe your scenario planning needs:

```
"I need to develop scenarios for my company."
```

or

```
"Let's explore future scenarios for renewable energy infrastructure."
```

If you have materials (decks, memos, PDFs), place them in `resources/` before you start.
Dr. Wells will automatically index them and use them to seed the interview.

### 3. Choose Your Starting Point

Dr. Wells will ask: **"Do you have a clear focal question, or should I interview you about your company first?"**

**Recommended:** Choose interview - Phase 0 discovery helps generate better focal questions and provides specialists with context

**Fast path:** Provide focal question directly - basic company info is still captured but deep research is skipped

Phase 0 typically takes 30-45 minutes (includes 6 specialist consultations + user interview rounds).

### 4. Dr. Wells Handles Everything

She will:
- Initialize the scenario automatically
- Conduct company discovery (if selected)
- Guide you through the 7-phase process
- Consult specialists as needed
- Track progress with TodoWrite
- Ensure quality and documentation

**You never need to run scripts manually.** Dr. Wells manages the technical details.

## Dependencies

### Required: Perplexity CLI (pp-cli)

This system requires [pp-cli](https://github.com/dbmcco/pp-cli) for specialist research capabilities.

**Installation:**
```bash
# Install pp-cli globally
npm install -g @dbmcco/pp-cli

# Verify installation
pp --version
```

**Why it's needed:**
- Specialists use `pp-cli` to conduct real-time research during scenario planning
- Provides current data on markets, technologies, policies, and trends
- Supports both quick lookups and deep research analysis
- Used throughout Phase 0 discovery and subsequent phases

**Without pp-cli:**
- Specialists can still provide analysis based on domain expertise
- Research findings will be limited to pre-existing knowledge
- Recommended to install for full functionality

## Exports (Optional)

The moderator may generate model-mediated HTML or TypeScript exports when helpful.
Exports live at `scenarios/active/SCENARIO-YYYY-NNN/exports/`.

## Architecture

### Directory Structure

```
shell-scenario-panel/
├── .claude/
│   ├── config.json                  # Project configuration
│   ├── settings.local.json          # Tool permissions
│   ├── hooks/                       # Quality enforcement
│   │   ├── pre-session.sh           # Scenario validation
│   │   ├── post-specialist-consultation.sh  # Transcript enforcement
│   │   └── scenario-validation.sh   # Phase completion checks
│   ├── scenario-init.sh             # Create new scenario
│   ├── list-scenarios.sh            # View all scenarios
│   └── archive-scenario.sh          # Archive completed work
├── scenarios/
│   ├── active/                      # Current scenario planning
│   └── archived/                    # Completed scenarios
├── resources/                      # Optional input materials for auto-intake
├── prompts/
│   ├── moderator.md                 # Dr. Michelle Wells
│   └── specialists/                 # 6 domain specialists
│       ├── ecologist.md             # Dr. Elena Vasquez
│       ├── geopolitician.md         # Dr. Marcus Chen
│       ├── anthropologist.md        # Dr. Aisha Okonkwo
│       ├── futurist.md             # Dr. Kenji Tanaka
│       ├── economist.md            # Dr. Sarah Blackwood
│       └── contrarian.md           # Dr. Jamie O'Sullivan
├── templates/                       # Scenario documents
│   ├── scenario_metadata.json
│   ├── focal_question.md
│   ├── predetermined_elements.md
│   ├── critical_uncertainties.md
│   └── scenario_narrative.md
└── CLAUDE.md                        # Facilitator instructions

```

## The 7-Phase Process

### Phase 0: Company Discovery (NEW)

**Purpose:** Build comprehensive understanding of company context through intelligent interview loop and specialist research.

**Process:**
1. Dr. Wells interviews user (2-3 basic questions: company, industry, size, business model)
2. All 6 specialists research company/market from their domain perspectives
3. Research findings inform follow-up questions for user
4. Iterate until comprehensive picture emerges (typically 1-3 rounds)
5. Dr. Wells generates 3-4 AI-recommended focal questions based on discoveries

**Outputs:**
- `company.md` - Comprehensive company profile
- `phase_0_discovery/internal_baseline.md` - User base case and risk posture
- `phase_0_discovery/materials_index.md` - Auto-generated index of `resources/` inputs
- `phase_0_discovery/research/` - 6 specialist discovery transcripts (per round)
- `scenario_suggestions.md` - AI-generated focal question recommendations

**User chooses:** Pick recommended question or provide their own → Proceed to Phase 1

**Can be skipped:** If user has clear focal question, basic company info is captured but deep discovery is optional.

---

### Phase 1: Understand the Focal Question
Clarify decision context, time horizon, scope, and assumptions (now streamlined since Phase 0 provides context)

### Phase 2: Identify Predetermined Elements
Map trends already in motion (demographics, infrastructure, debt, climate)

Specialists now reference Phase 0 context and discovery findings

### Phase 3: Identify Critical Uncertainties
Surface factors that could go multiple ways and matter for decisions

### Phase 4: Develop Scenario Narratives
Create 4 plausible, divergent future scenarios with memorable names

### Phase 5: Identify Early Warning Signals
Define observable indicators for each scenario

### Phase 6: Test Strategies
Explore strategy performance across scenarios, identify robust approaches

## Specialist Team

Each specialist brings unique perspective and characteristic blind spots:

| Specialist | Focus Area | Strengths |
|------------|------------|-----------|
| **Elena Vasquez** | Systems Ecology | Feedback loops, interdependencies, resilience |
| **Marcus Chen** | Geopolitics | Power dynamics, resources, state interests |
| **Aisha Okonkwo** | Cultural Anthropology | Values, meaning-making, lived experience |
| **Kenji Tanaka** | Technology Futures | Capability thresholds, platform shifts, S-curves |
| **Sarah Blackwood** | Economics | Debt dynamics, financial structures, regime shifts |
| **Jamie O'Sullivan** | Contrarian Provocateur | Hidden risks, fragilities, challenging assumptions |

## Key Features

### File Placement Enforcement (Programmatic)

**Problem:** Prompting specialists about file paths is unreliable.

**Solution:** Three-layer programmatic enforcement:

1. **Path Generation** (`.claude/lib/generate-specialist-prompt.sh`)
   - Pre-calculates exact file paths before specialist invocation
   - Generates prompts with explicit requirements
   - Warns that validation will check

2. **Output Validation** (`.claude/lib/validate-specialist-output.sh`)
   - Validates files exist at correct paths after specialist returns
   - Checks minimum file sizes (summaries: 100 bytes, full: 500 bytes)
   - Returns detailed error reports

3. **Blocking Progression** (moderator workflow)
   - Moderator validates after each specialist invocation
   - Re-invokes once if validation fails
   - Only proceeds after validation passes

**Benefits:**
- ✅ Deterministic paths (calculated, not guessed)
- ✅ Automatic validation (catches errors immediately)
- ✅ Blocking behavior (can't proceed with bad data)
- ✅ Clear error messages (tells specialist what's missing)

### Transcript Enforcement (Claude Code 2.0 Pattern)

**Moderator (Dr. Wells) enforces transcripts** - hooks provide reminders only.

**Multi-layer approach:**

1. **Specialist prompts** - OUTPUT FORMAT section with explicit transcript requirements
2. **Moderator protocol** - Dr. Wells verifies transcript after each consultation
3. **post-task hook** - Reminds moderator of responsibilities (doesn't block)
4. **TodoWrite tracking** - Moderator tracks consultations and validations
5. **Metadata records** - All consultations logged with transcript paths

**Key insight:** Hooks can't check specialist-specific work because they lack context. The moderator uses Task tool to invoke specialists and immediately verifies their output.

### Quality Gates (Automated Enforcement)

**Automated Quality Analysis:**
The system includes **Dr. Mei Chen (Quality Analyst)** - an 8th specialist who audits intellectual integrity and prevents quality regression.

**Automatic Triggers (via hooks):**
When phase synthesis documents are created, the system automatically prompts for quality analysis:
- **Phase 2 completion** (`predetermined_elements.md`) → Quality gate checkpoint
- **Phase 3 completion** (`critical_uncertainties.md`) → Quality gate checkpoint
- **Phase 4 completion** (scenario files) → Quality gate checkpoint
- **Executive Summary** → Final quality gate

**Quality Analyst evaluates:**
- Has synthesis quality regressed from specialist quality?
- Are specialist frameworks and terminology preserved?
- Has iteration diluted sophistication (Round 3 < Round 1)?
- Are there generic contamination patterns (web search, startup advice)?
- Does language maintain expert-level rigor?

**Pass/Fail Enforcement:**
- **PASS:** Proceed to next phase
- **CONDITIONAL PASS:** Fix issues before user delivery
- **FAIL:** Rewrite synthesis using specialist transcripts, cannot proceed

**Dr. Wells is also responsible for:**
- Verifying transcripts exist with substantial analysis (>100 words summaries, >500 words full)
- Synthesizing specialist insights into phase documents
- Getting user validation before each new specialist
- Updating metadata to track all consultations
- Using TodoWrite to show workflow progress

**Example Quality Gate:**
```
⚠️  QUALITY GATE REQUIRED: phase_2

Phase synthesis detected: predetermined_elements.md

📋 MODERATOR ACTION REQUIRED:

Task("quality_analyst", "SCENARIO: SCENARIO-2025-001
CHECKPOINT: phase_2
Evaluate intellectual integrity and quality regression.
TRANSCRIPT PATH: conversations/quality_analyst_phase_2.md")

⛔ CANNOT PROCEED to next phase until quality gate PASSES
```

### Scenario Management

```bash
# Initialize new scenario
.claude/scenario-init.sh

# List all scenarios
.claude/list-scenarios.sh

# Archive completed scenario
.claude/archive-scenario.sh SCENARIO-2025-001
```

### Example Specialist Consultation

```
Dr. Wells (via Task tool):

Task("economist", "SCENARIO: SCENARIO-2025-001

QUESTION: What debt structures and financial obligations are already in place that will constrain policy choices over the next 10 years?

TRANSCRIPT PATH: scenarios/active/SCENARIO-2025-001/conversations/economist_transcript.md

Analyze from your financial-structural perspective and create the transcript as specified.")
```

After Task completes, Dr. Wells:
1. Reads `conversations/economist_transcript.md`
2. Verifies >100 words of analysis
3. Synthesizes insights into `predetermined_elements.md`
4. Updates metadata with consultation record
5. Uses TodoWrite to track progress
6. Presents findings to user for validation

## Scenario Output Structure

Each scenario produces:

```
scenarios/active/SCENARIO-YYYY-NNN/
├── metadata.json                    # Tracking and status
├── scenario_context.md              # User feedback accumulation
├── company.md                       # Company profile (if Phase 0 used)
├── focal_question.md                # Phase 1: Decision context
├── predetermined_elements.md        # Phase 2: Locked-in trends
├── critical_uncertainties.md        # Phase 3: Key uncertainties
├── scenarios/                       # Phase 4: Future narratives
│   ├── scenario_1_[name].md
│   ├── scenario_2_[name].md
│   ├── scenario_3_[name].md
│   └── scenario_4_[name].md
├── strategy_analysis.md             # Phase 6: Strategy testing
├── conversations/                   # Required specialist transcripts
│   ├── ecologist_round1_full.md
│   ├── ecologist_round1_summary.md
│   ├── economist_round1_full.md
│   └── [etc...]
└── phase_0_discovery/               # Phase 0 outputs (if used)
    ├── scenario_suggestions.md
    └── research/
        └── [specialist discovery transcripts]
```

## Philosophy

**Scenarios are not predictions.** They are:
- **Plausible** - Internally consistent and grounded in reality
- **Challenging** - Stretch thinking beyond comfortable assumptions
- **Relevant** - Illuminate decisions that need to be made
- **Divergent** - Explore genuinely different futures
- **Memorable** - People can recall and reason with them

The goal is preparing minds for multiple futures, identifying robust strategies, and making better decisions under uncertainty.

## Based On

This system adapts:
- **Shell Methodology** - Classic scenario planning approach from Pierre Wack and Ted Newland
- **DraftForge Architecture** - Multi-agent workflow patterns from lfw-draftforge-poc
- **Transcript Enforcement** - Lessons learned from agent coordination challenges

## Usage Tips

1. **Start with clear decision context** - The focal question shapes everything
2. **Consult specialists strategically** - Not every phase needs all 6 perspectives
3. **Validate continuously** - Get user confirmation before moving forward
4. **Synthesize, don't concatenate** - Weave specialist insights into coherent understanding
5. **Make scenarios vivid** - They should be memorable enough to shift mental models

---

**Ready to explore multiple futures? Initialize a scenario and begin.**
