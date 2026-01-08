# Quick Start Guide

## How to Use Shell Scenario Panel

### Step 1: Prerequisites

**Install pp-cli:**
```bash
npm install -g @dbmcco/pp-cli
pp --version
```

**Install the worldview-elicitor skill (bundled with this repo):**
```bash
# From the shell-scenario-panel directory
mkdir -p ~/.claude/skills
ln -s "$(pwd)/skills/worldview-elicitor" ~/.claude/skills/worldview-elicitor
```

### Step 2: Clone and Start Claude Code
```bash
git clone https://github.com/dbmcco/shell-scenario-panel.git
cd shell-scenario-panel
# Start your Claude Code session here
```

### Step 3: Tell Dr. Wells What You Want

Just start talking about your scenario planning needs:

**Example:**
> "I need to explore future scenarios for renewable energy policy over the next 15 years. We're making infrastructure investment decisions and need to understand multiple possible futures."

**Or simply:**
> "Let's do scenario planning for AI regulation."

### Step 4: Dr. Wells Takes Over

She will automatically:
1. Initialize a new scenario
2. **Elicit your worldview** (Phase 0) - understand how you think about the topic
3. Clarify your focal question (Phase 1)
4. Consult specialists strategically (Phases 2-6)
5. Develop 4 divergent scenarios
6. **Integrate with your worldview** (Phase 7) - connect scenarios to your mental model
7. Track progress with TodoWrite

## You Don't Need To:
- Run any bash scripts manually
- Export environment variables
- Manage file structures
- Track which phase you're in

## Dr. Wells Handles:
- Scenario initialization and management
- Worldview elicitation and integration
- Specialist consultation and coordination
- Transcript verification and quality control
- Progress tracking and documentation
- User validation at each phase

## The 8 Phases

0. **Worldview Elicitation** - Understand how you think about this topic
1. **Understanding** - Clarify your focal question and decision context
2. **Predetermined Elements** - Identify trends already locked in
3. **Critical Uncertainties** - Surface factors that could go multiple ways
4. **Scenario Development** - Create 4 plausible, divergent futures
5. **Early Warning Signals** - Define indicators for each scenario
6. **Strategy Testing** - Identify robust strategies across scenarios
7. **Worldview Integration** - Connect scenarios back to your mental model

## Example Session: The New Flow

**You:** I want to develop scenarios for the future of autonomous vehicles.

**Dr. Wells:** I'll help you explore that. First, I want to understand how you're currently thinking about this space.

*[Phase 0: Worldview Elicitation begins]*

**Dr. Wells:** What's your sense of how autonomous vehicles will develop over the next decade?

**You:** I think we're about 5 years from widespread Level 4 autonomy. The technology is basically ready, it's just regulatory and infrastructure.

**Dr. Wells:** What makes you think the technology is basically ready?

**You:** I've seen the demos, read about the progress. Tesla, Waymo - they're getting close.

**Dr. Wells:** What would have to be true for that timeline to slip significantly?

**You:** I guess if there were major accidents that set back public trust. Or if the edge cases turn out to be harder than expected.

**Dr. Wells:** Those sound like genuine uncertainties. How confident are you in the 5-year timeline?

**You:** Honestly, maybe 60%? The technical challenges keep being "almost solved."

*[Dr. Wells continues elicitation, capturing beliefs, reasoning, uncertainties, cruxes...]*

**Dr. Wells:** Let me summarize your worldview:
- **Core prediction:** Widespread Level 4 autonomy in ~5 years
- **Reasoning:** Technology progress from major players
- **Key uncertainty:** Whether edge cases are harder than expected
- **Crux:** Major accidents could set back public trust significantly
- **Confidence:** ~60%

Does that capture how you're thinking about this?

**You:** Yes, that's about right.

*[Phase 0 complete - worldview_model.md created]*

**Dr. Wells:** Now let's explore the external landscape. What decision are you facing that depends on how autonomous vehicles develop?

*[Phases 1-6 proceed normally, developing 4 scenarios]*

---

*[After Phase 6 completes...]*

*[Phase 7: Worldview Integration begins]*

**Dr. Wells:** Now let me connect these four scenarios back to how you were thinking about autonomous vehicles at the start.

**Your belief that "technology is basically ready":**
- **Scenario A (Rapid Adoption):** Confirmed - technical breakthroughs accelerate timeline
- **Scenario B (Regulatory Gridlock):** Technology ready but blocked by policy
- **Scenario C (Fragmented Standards):** Technology varies by region, no universal solution
- **Scenario D (Extended Transition):** Edge cases harder than expected - challenges your belief

**Your crux about major accidents:**
This is actually what separates Scenarios A/B from C/D. Early warning signals for you:
- Watch for: First fatal accident in fully autonomous mode
- Watch for: Regulatory response to near-misses

**Dr. Wells:** Having explored these four futures, has anything shifted in how you're thinking about this?

**You:** I hadn't really considered Scenario C - that different regions might solve it differently. And Scenario D made me question my assumption that the edge cases are almost solved.

*[Phase 7 complete - worldview_integration.md created]*

---

## Output

You'll receive:
- `worldview_model.md` - Your captured mental model
- 4 detailed scenario narratives with memorable names
- `worldview_integration.md` - How scenarios connect to your beliefs
- Personalized early warning signals based on your cruxes
- Strategic recommendations
- All documentation in `scenarios/active/SCENARIO-YYYY-NNN/`

---

**Ready to start?** Just open Claude Code and describe what future you want to explore.
