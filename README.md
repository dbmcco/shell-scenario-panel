# Shell Scenario Panel

A Claude Code-powered Shell-style scenario planning system with multi-specialist consultation, worldview integration, and rigorous documentation enforcement.

## Overview

This is a structured scenario planning tool based on the Shell methodology, featuring:
- **Dr. Michelle Wells** (Moderator) - Facilitates 8-phase scenario development process
- **Worldview Elicitation** - Understands how you think about the topic before exploring scenarios
- **6 Domain Specialist Consultants** - Diverse expert perspectives (ecology, geopolitics, culture, technology, economics, contrarian)
- **Dr. Anya Petrov** (Research Specialist) - Multi-source research and fact-checking
- **Dr. Mei Chen** (Quality Analyst) - Automated quality gates prevent regression to generic analysis
- **Worldview Integration** - Connects scenarios back to your mental model
- **Automated Quality Enforcement** - Hooks trigger quality gates, ensure intellectual integrity

## The "Lens-World-Lens" Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 0: WORLDVIEW ELICITATION                                │
│  Understand how you think about this topic                     │
│  OUTPUT: worldview_model.md                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  PHASES 1-6: EXTERNAL SCENARIO PLANNING                        │
│  Focal question → Predetermined → Uncertainties → Scenarios    │
│  OUTPUT: 4 divergent scenarios                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 7: WORLDVIEW INTEGRATION                                │
│  Connect scenarios to your mental model                        │
│  OUTPUT: worldview_integration.md                              │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Prerequisites

**Required: Perplexity CLI (pp-cli)**

```bash
npm install -g @dbmcco/pp-cli
pp --version
```

**Required: worldview-elicitor skill**

The worldview-elicitor skill must be available in your Claude Code environment. See [Skills Setup](#skills-setup) below.

### 2. Clone and Start Your Agent (Claude or Codex)

```bash
git clone https://github.com/dbmcco/shell-scenario-panel.git
cd shell-scenario-panel
# Start Claude Code or Codex conversation
```

### 3. Tell Dr. Wells What You Want to Explore

Just describe your scenario planning needs:

```
"I need to develop scenarios for the future of AI regulation."
```

or

```
"Let's explore future scenarios for renewable energy infrastructure."
```

### 4. Dr. Wells Handles Everything

She will:
1. Initialize the scenario automatically
2. **Elicit your worldview** - understand how you think about this topic
3. Guide you through the 8-phase process
4. Consult specialists as needed
5. **Integrate scenarios with your worldview** - connect findings to your mental model
6. Ensure quality and documentation

**You never need to run scripts manually.** Dr. Wells manages the technical details.

---

## Agent Runbook (Claude/Codex)

Use this section if you are operating as the facilitator agent inside this repo.

### 1. Start the session bootstrap script

```bash
# Claude sessions
.claude/session-start.sh

# Codex sessions
.codex/session-start.sh
```

Use `--scenario SCENARIO-YYYY-NNN`, `--new`, or `--monitor SCENARIO-YYYY-NNN` as needed.

### 2. Handle resources before interviewing

- Check `resources/` for user-provided files (ignore `README.md`, `.gitkeep`, `.DS_Store`)
- Ask whether to scan and incorporate those materials
- If yes, run `.claude/lib/resources-intake.sh "$SCENARIO_ID"`
- Review `scenarios/active/$SCENARIO_ID/phase_0_discovery/materials_index.md` with the user before proceeding

### 3. Follow the moderator flow and phase gates

- Treat `prompts/moderator.md` as the canonical facilitation sequence
- Complete Phase 0 deliverables before external analysis:
- `worldview_model.md`
- `phase_0_discovery/internal_baseline.md`
- `phase_0_discovery/context_packet.md`
- Do not bypass transcript checks, metadata updates, or quality checkpoints

### 4. Use the right instruction file for your agent

- Claude agent instructions: `CLAUDE.md`
- Codex agent instructions: `CODEX.md`

If there is any conflict, follow the agent-specific file for your runtime.

---

## Recommended Input Documents

Place materials in `resources/` before starting. The panel performs best when grounded in concrete context about your focal topic.

### Required (Scenario Foundation)

| Document | Why It Matters |
|----------|---------------|
| **Focal Topic Brief** | 1-2 pages defining what you want to explore, including time horizon (5, 10, 20 years) and geographic/industry scope |
| **Current State Snapshot** | What the world looks like today in your focal area — statistics, trends, key players, recent developments |

### High-Value (Enriches Scenarios)

| Document | Why It Matters |
|----------|---------------|
| **Historical Trend Data** | How your focal area has evolved over the past 5-20 years; patterns reveal what's truly predetermined vs uncertain |
| **Stakeholder Map** | Key actors (companies, governments, institutions) and their interests; Marcus (geopolitics) and Sarah (economics) need this |
| **Explicit Constraints** | What you already know is locked in — budgets, infrastructure timelines, regulatory frameworks, demographic shifts |
| **Prior Analysis** | Existing strategy documents, forecasts, or expert opinions you've gathered; specialists can build on or challenge these |

### Nice-to-Have (Adds Depth)

| Document | Why It Matters |
|----------|---------------|
| **Technology Roadmaps** | Capability timelines for relevant technologies; Kenji (futurist) uses these to identify inflection points |
| **Cultural Context** | How different communities think about your topic; Aisha (anthropologist) grounds scenarios in lived experience |
| **Contrarian Views** | Perspectives that challenge conventional wisdom; Jamie (contrarian) amplifies these to stress-test scenarios |

### Format Tips

- **Define your time horizon explicitly** — scenarios for 2030 require different inputs than 2050
- **Include sources and dates** — specialists weight recent data more heavily
- **Separate facts from assumptions** — label what you know vs what you believe
- **Multiple perspectives welcome** — conflicting expert views often reveal critical uncertainties

---

## The 8-Phase Process

### Phase 0: Worldview Elicitation (NEW)

**Purpose:** Understand how you think about the topic before exploring external scenarios.

**Process:**
1. Dr. Wells invokes the worldview-elicitor skill
2. Natural conversation to surface your beliefs, reasoning, and uncertainties
3. Captures what would change your mind (cruxes)
4. Documents your mental models and frameworks

**Output:** `worldview_model.md`

**Also captured:** `phase_0_discovery/internal_baseline.md` (structured base case and risk posture)

**Why this matters:**
- Scenarios become more relevant (we know what lens you're looking through)
- Helps identify blind spots (where your worldview differs from scenario implications)
- Creates better buy-in (scenarios framed in your language/concepts)
- Reveals which scenarios you'll naturally resist or accept

---

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

---

### Phase 7: Worldview Integration (NEW)

**Purpose:** Connect scenarios back to your mental model and prepare you for multiple futures.

**Process:**
1. **Belief-by-belief analysis** - Shows how each of your beliefs fares across all 4 scenarios
2. **Specialist reactions** - Domain experts comment on where your worldview might be missing something
3. **Crux-to-scenario mapping** - Shows how your uncertainties map to scenario boundaries
4. **Personalized early warnings** - Signals that would confirm or challenge your current view
5. **Reflection** - Exploratory conversation about what shifted in your thinking

**Output:** `worldview_integration.md`

**This is not persuasion.** The goal is helping you see how different futures connect to your existing understanding.

---

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

## Architecture

### Directory Structure

```
shell-scenario-panel/
├── .claude/
│   ├── config.json                  # Project configuration
│   ├── settings.local.json          # Tool permissions
│   ├── hooks/                       # Quality enforcement
│   ├── scenario-init.sh             # Create new scenario
│   ├── list-scenarios.sh            # View all scenarios
│   ├── validate-scenario.sh         # Validate scenario completeness
│   └── archive-scenario.sh          # Archive completed work
├── scenarios/
│   ├── active/                      # Current scenario planning
│   └── archived/                    # Completed scenarios
├── prompts/
│   ├── moderator.md                 # Dr. Michelle Wells
│   └── specialists/                 # 6 domain specialists
├── skills/                          # Bundled Claude Code skills
│   └── worldview-elicitor/          # Phase 0 elicitation skill
├── templates/                       # Scenario document templates
│   ├── worldview_model.md           # Phase 0 template
│   ├── worldview_integration.md     # Phase 7 template
│   ├── focal_question.md
│   └── [other templates...]
└── CLAUDE.md                        # Facilitator instructions
```

### Scenario Output Structure

Each scenario produces:

```
scenarios/active/SCENARIO-YYYY-NNN/
├── metadata.json                    # Tracking and status
├── worldview_model.md               # Phase 0: Your mental model
├── scenario_context.md              # User feedback accumulation
├── focal_question.md                # Phase 1: Decision context
├── predetermined_elements.md        # Phase 2: Locked-in trends
├── critical_uncertainties.md        # Phase 3: Key uncertainties
├── scenarios/                       # Phase 4: Future narratives
│   ├── scenario_1_[name].md
│   ├── scenario_2_[name].md
│   ├── scenario_3_[name].md
│   └── scenario_4_[name].md
├── strategy_analysis.md             # Phase 6: Strategy testing
├── worldview_integration.md         # Phase 7: Connected to your model
├── conversations/                   # Specialist transcripts
│   ├── ecologist_round1_full.md
│   ├── economist_round1_full.md
│   ├── contrarian_worldview_reaction.md  # Phase 7
│   └── [etc...]
└── artifacts/                       # Supporting files
```

## Skills Setup

### worldview-elicitor Skill

The worldview-elicitor skill is required for Phase 0. It is bundled with this repository.

**Installation:**

```bash
# From the shell-scenario-panel directory
mkdir -p ~/.claude/skills
ln -s "$(pwd)/skills/worldview-elicitor" ~/.claude/skills/worldview-elicitor
```

**Verification:**
```bash
ls ~/.claude/skills/worldview-elicitor/
# Should show: skill.md
```

See `skills/README.md` for more details.

## Key Features

### Worldview-Centric Design

The system is built around understanding YOUR perspective:
- **Phase 0** captures how you think before showing you anything
- **Phases 1-6** explore the external world objectively
- **Phase 7** translates findings back through your lens

This means scenarios are:
- More personally relevant
- Framed in language you understand
- Connected to your existing mental models
- Explicit about where they confirm or challenge your view

### Model-Mediated Guardrails

The system keeps reflection explicit while forcing constructive opposition:
- **Calibration:** user familiarity + facilitation stance (mirror / hybrid / analytic)
- **Not-knowing diagnostic:** actions, outcomes, causation, value, with tool matching
- **Mirror / Opposition / Synthesis:** preserve input reflection and stress-test it
- **Provenance logging:** new inputs tracked as claims with confidence and falsifiers
- **Progressive disclosure:** plain-language summary first, optional technical notes second

See `docs/model-guardrails-proposal.html` for the full guardrail rationale and implementation map.

### Transcript Enforcement

**Moderator (Dr. Wells) enforces transcripts** - hooks provide reminders only.

Multi-layer approach:
1. Specialist prompts with explicit transcript requirements
2. Moderator verifies transcript after each consultation
3. Post-task hooks remind of responsibilities
4. Metadata records all consultations with transcript paths

### Quality Gates

Automated quality analysis at key checkpoints:
- Phase 2 completion
- Phase 3 completion
- Phase 4 completion
- Executive Summary

Quality Analyst evaluates intellectual integrity and prevents regression to generic analysis.

### Scenario Management

```bash
# Initialize new scenario
.claude/scenario-init.sh

# List all scenarios
.claude/list-scenarios.sh

# Validate scenario completeness
.claude/validate-scenario.sh SCENARIO-2025-001

# Archive completed scenario
.claude/archive-scenario.sh SCENARIO-2025-001
```

## Philosophy

**Scenarios are not predictions.** They are:
- **Plausible** - Internally consistent and grounded in reality
- **Challenging** - Stretch thinking beyond comfortable assumptions
- **Relevant** - Illuminate decisions that need to be made
- **Divergent** - Explore genuinely different futures
- **Memorable** - People can recall and reason with them
- **Personal** - Connected to your worldview, not generic

**Worldview integration is not persuasion.** It's helping you see how different futures connect to your existing understanding.

The goal is preparing minds for multiple futures, identifying robust strategies, and making better decisions under uncertainty.

## Usage Tips

1. **Be honest in Phase 0** - The more accurately we capture your worldview, the better the integration
2. **Embrace uncertainty** - Saying "I don't know" is valuable information
3. **Notice resistance** - Scenarios that feel implausible may reveal blind spots
4. **Watch your cruxes** - The early warning signals for your specific uncertainties are most valuable
5. **Reflect genuinely** - Phase 7 reflection is for you, not for us

## Export to Keynote Slides

Convert your scenario planning outputs into a presentation deck using the keynote-slides skill.

### Export the brief

```bash
.claude/export-deck-brief.sh SCENARIO-2025-001
```

This consolidates: focal question, predetermined elements, critical uncertainties, all four scenarios, early warning signals, strategy analysis, and key specialist insights.

### Copy to your deck

```bash
# Create a new deck
cd ../keynote-slides-skill
scripts/new-deck.sh futures-deck --entity acme --title "Strategic Futures" --type strategy

# Copy the brief as materials
cp ../ai-simulations/shell-scenario-panel/scenarios/active/SCENARIO-2025-001/deck-brief.md \
   decks/futures-deck/resources/materials/
```

The narrative engine will help match your scenarios to storytelling frameworks like "Time Machine" (future vision) or "Rashomon" (multiple perspectives).

---

## Based On

This system adapts:
- **Shell Methodology** - Classic scenario planning approach from Pierre Wack and Ted Newland
- **Worldview Elicitation** - Techniques from forecasting and calibration training
- **Lens-World-Lens Architecture** - Novel integration of internal models with external scenarios

---

**Ready to explore multiple futures? Initialize a scenario and begin.**
