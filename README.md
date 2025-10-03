# Shell Scenario Panel

A Claude Code-powered Shell-style scenario planning system with multi-specialist consultation and rigorous documentation enforcement.

## Overview

This is a structured scenario planning tool based on the Shell methodology, featuring:
- **Dr. Michelle Wells** (Moderator) - Facilitates 6-phase scenario development process
- **6 Specialist Consultants** - Domain experts providing diverse perspectives
- **Automated Workflow** - Hooks enforce quality standards and transcript creation
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
"I need to develop scenarios for AI regulation over the next decade."
```

or

```
"Let's explore future scenarios for renewable energy infrastructure."
```

### 3. Dr. Wells Handles Everything

She will:
- Initialize the scenario automatically
- Guide you through the 6-phase process
- Consult specialists as needed
- Track progress with TodoWrite
- Ensure quality and documentation

**You never need to run scripts manually.** Dr. Wells manages the technical details.

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

## The 6-Phase Process

### Phase 1: Understand the Focal Question
Clarify decision context, time horizon, scope, and assumptions

### Phase 2: Identify Predetermined Elements
Map trends already in motion (demographics, infrastructure, debt, climate)

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

### Transcript Enforcement (Claude Code 2.0 Pattern)

**Moderator (Dr. Wells) enforces transcripts** - hooks provide reminders only.

**Multi-layer approach:**

1. **Specialist prompts** - OUTPUT FORMAT section with explicit transcript requirements
2. **Moderator protocol** - Dr. Wells verifies transcript after each consultation
3. **post-task hook** - Reminds moderator of responsibilities (doesn't block)
4. **TodoWrite tracking** - Moderator tracks consultations and validations
5. **Metadata records** - All consultations logged with transcript paths

**Key insight:** Hooks can't check specialist-specific work because they lack context. The moderator uses Task tool to invoke specialists and immediately verifies their output.

### Quality Gates (Moderator-Enforced)

**Dr. Wells is responsible for:**
- Verifying transcripts exist with substantial analysis (>100 words)
- Synthesizing specialist insights into phase documents
- Getting user validation before each new specialist
- Updating metadata to track all consultations
- Using TodoWrite to show workflow progress

**Hooks provide:**
- Session startup information
- Post-task reminders about verification responsibilities
- No blocking validation (moderator enforces quality)

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
├── focal_question.md                # Phase 1: Decision context
├── predetermined_elements.md        # Phase 2: Locked-in trends
├── critical_uncertainties.md        # Phase 3: Key uncertainties
├── scenarios/                       # Phase 4: Future narratives
│   ├── scenario_1_[name].md
│   ├── scenario_2_[name].md
│   ├── scenario_3_[name].md
│   └── scenario_4_[name].md
├── strategy_analysis.md             # Phase 6: Strategy testing
├── conversations/                   # Required transcripts
│   ├── ecologist_transcript.md
│   ├── economist_transcript.md
│   └── [etc...]
└── artifacts/                       # Supporting materials
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
