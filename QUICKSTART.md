# Quick Start Guide

## How to Use Shell Scenario Panel

### Step 1: Start Claude Code
```bash
cd /Users/braydon/projects/experiments/ai-simulations/shell-scenario-panel
# Start your Claude Code session here
```

### Step 2: Tell Dr. Wells What You Want

Just start talking about your scenario planning needs:

**Example:**
> "I need to explore future scenarios for renewable energy policy over the next 15 years. We're making infrastructure investment decisions and need to understand multiple possible futures."

**Or simply:**
> "Let's do scenario planning for AI regulation."

### Step 3: Dr. Wells Takes Over

She will automatically:
1. Initialize a new scenario (runs `.claude/scenario-init.sh` for you)
2. Guide you through Phase 1: Understanding your focal question
3. Consult specialists strategically via Task tool
4. Track progress with TodoWrite
5. Synthesize insights for your validation
6. Continue through all 6 phases until complete

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

## The 6 Phases

Dr. Wells will guide you through:

1. **Understanding** - Clarify your focal question and decision context
2. **Predetermined Elements** - Identify trends already locked in
3. **Critical Uncertainties** - Surface factors that could go multiple ways
4. **Scenario Development** - Create 4 plausible, divergent futures
5. **Early Warning Signals** - Define indicators for each scenario
6. **Strategy Testing** - Identify robust strategies across scenarios

## Output

You'll receive:
- 4 detailed scenario narratives with memorable names
- Early warning signals for each scenario
- Strategic recommendations
- All documentation in `scenarios/active/SCENARIO-YYYY-NNN/`

---

**Ready to start?** Just open Claude Code and describe what future you want to explore.
