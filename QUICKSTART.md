# Quick Start Guide

## How to Use Shell Scenario Panel

### Step 1: Clone and Start Claude Code
```bash
git clone https://github.com/dbmcco/shell-scenario-panel.git
cd shell-scenario-panel
# Start your Claude Code session here
```

**Codex CLI:** run the bootstrapper first to enforce sequencing:
```bash
.codex/session-start.sh
```

### Step 2: Tell Dr. Wells What You Want

Just start talking about your scenario planning needs:

**Example:**
> "I need to explore future scenarios for renewable energy policy over the next 15 years. We're making infrastructure investment decisions and need to understand multiple possible futures."

**Or simply:**
> "Let's do scenario planning for AI regulation."

If you have materials (decks, memos, PDFs), drop them into `resources/` before you start.

### Step 3: Dr. Wells Takes Over

She will automatically:
1. Initialize a new scenario (runs `.claude/scenario-init.sh` for you)
2. Index any materials in `resources/` and seed the interview if present
3. Offer Phase 0 discovery or direct to Phase 1
4. Conduct Phase 0 elicitation and company discovery if selected
5. Consult specialists strategically via Task tool
6. Track progress with TodoWrite
7. Synthesize insights for your validation
8. Continue through all 7 phases until complete
9. Optionally export HTML or TypeScript outputs for review

## You Don't Need To:
- ❌ Run any bash scripts manually
- ❌ Export environment variables
- ❌ Manage file structures
- ❌ Track which phase you're in

## Dr. Wells Handles:
- ✅ Scenario initialization and management
- ✅ Specialist consultation and coordination
- ✅ Transcript verification and quality control
- ✅ Progress tracking and documentation
- ✅ User validation at each phase

## Example Opening Messages

**Strategic Business Decision:**
> "We're a tech company deciding whether to invest heavily in quantum computing R&D. We need scenarios for how the quantum computing landscape might evolve over the next 10 years."

**Policy Planning:**
> "Help me develop scenarios for how climate policy could evolve in the US over the next 20 years. We're planning long-term infrastructure investments."

**Market Analysis:**
> "I need to understand possible futures for the electric vehicle market over the next decade. What scenarios should we prepare for?"

## The 7 Phases

Dr. Wells will guide you through:

0. **Company Discovery (NEW)** - Intelligent interview loop with specialist research to generate focal question recommendations
1. **Understanding** - Clarify your focal question and decision context
2. **Predetermined Elements** - Identify trends already locked in
3. **Critical Uncertainties** - Surface factors that could go multiple ways
4. **Scenario Development** - Create 4 plausible, divergent futures
5. **Early Warning Signals** - Define indicators for each scenario
6. **Strategy Testing** - Identify robust strategies across scenarios

## Quick Example: Starting with Phase 0 Discovery

**You:** I want to develop scenarios for my company

**Dr. Wells:** Do you have a clear focal question, or should I interview you about your company first?

**You:** Interview me

**Dr. Wells:** What's your company name and what industry are you in?

**You:** We're TechFab, a semiconductor equipment manufacturer

**Dr. Wells:** What's your company size and stage?

**You:** $200M revenue, 500 employees, growth stage

**Dr. Wells:** What's your core business model?

**You:** We sell lithography equipment to chip manufacturers

**Dr. Wells:** I'm consulting all 6 specialists to research your industry and market context - this will take 10-15 minutes.

[6 specialists research semiconductor equipment industry]

**Dr. Wells:** Here's what the specialists discovered:

**Common themes:**
- Economist: Massive CapEx concentration in leading-edge nodes, Chinese self-sufficiency push
- Geopolitician: Export controls tightening, CHIPS Act driving US fab construction
- Futurist: EUV vs. High-NA EUV inflection point, AI chip demand surge
- Ecologist: Water and energy intensity of fabs, material scarcity for advanced equipment

**Questions that emerged:**
1. What % of revenue comes from Chinese customers?
2. Are you exposed to export control restrictions?
3. What's your R&D investment in next-gen technology?

[Interview continues for 1-2 more rounds based on findings]

**Dr. Wells:** Based on discovery, here are 3 recommended focal questions:

1. **The Geopolitical Bifurcation Question:** How should we position our product portfolio given uncertainty about US-China technology decoupling over 5 years?

2. **The Technology Transition Question:** When should we shift R&D investment from EUV to High-NA EUV given uncertain customer adoption timelines?

3. **The Market Concentration Question:** What customer diversification strategy maximizes resilience given TSMC/Samsung concentration risk?

**You:** Let's go with #1, the geopolitical question

**Dr. Wells:** [Offers refinements] → Proceeds to Phase 1 → ... → Develops 4 scenarios

## Output

You'll receive:
- 4 detailed scenario narratives with memorable names
- Early warning signals for each scenario
- Strategic recommendations
- All documentation in `scenarios/active/SCENARIO-YYYY-NNN/`

## Optional: Preview Exports

If HTML outputs are generated, you can preview them locally:
```bash
.claude/lib/serve-exports.sh SCENARIO-YYYY-NNN
```

---

**Ready to start?** Just open Claude Code and describe what future you want to explore.
