# Phase 0: Company Discovery Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add Phase 0 (Company Discovery) to enable intelligent interview loop, specialist research, and AI-generated focal question recommendations.

**Architecture:** Extend existing moderator/specialist consultation pattern with new Phase 0 that maintains company.md, orchestrates iterative discovery rounds, and generates scenario suggestions before handing off to existing Phase 1-6.

**Tech Stack:** Markdown prompt files, Perplexity CLI (pp-cli), Claude Code Task tool, JSON metadata

---

## Task 1: Create Template Files

**Files:**
- Create: `templates/company_profile.md`
- Create: `templates/scenario_suggestions.md`
- Create: `templates/discovery_transcript.md`

### Step 1: Create company profile template

Create `templates/company_profile.md`:

```markdown
# Company Profile: [COMPANY_NAME]

## Basic Information
- **Industry:** [industry]
- **Stage:** [startup/growth/mature]
- **Size:** [revenue/employees]
- **Business Model:** [description]
- **Geographic Markets:** [markets]
- **Strategic Context:** [user's stated challenge/decision]

## Business Details

### Operations
- [Supply chain details, manufacturing, delivery model, etc.]

### Market Position
- [Customers, competitors, market share, differentiation]

### Financials
- [Capital structure, profitability, funding, constraints]

### Capabilities
- [Technology, talent, IP, infrastructure, partnerships]

### Constraints & Risks
- [Regulatory, operational, financial, competitive pressures]

## Discovery History
**Round 1:** [Date] - Initial interview completed
**Round 2:** [Date] - Specialist research round 1
[Add rounds as they occur]
```

### Step 2: Create scenario suggestions template

Create `templates/scenario_suggestions.md`:

```markdown
# Scenario Suggestions for [COMPANY_NAME]

Based on discovery research by all 6 domain specialists, here are recommended focal questions for scenario development:

---

## Suggestion 1: [MEMORABLE_TITLE]

**Focal Question:** "[Specific strategic question with time horizon]"

**Why This Matters:**
[2-3 sentences on why this question emerged from research]
- **Economist found:** [key economic uncertainty]
- **Geopolitician found:** [key geopolitical risk/factor]
- **Futurist found:** [key technology/trend inflection point]
- **[Other specialists]:** [relevant findings]

**What This Would Explore:**
[What scenarios around this question would reveal - what strategic insights would emerge]

---

## Suggestion 2: [MEMORABLE_TITLE]

**Focal Question:** "[Specific strategic question with time horizon]"

**Why This Matters:**
[2-3 sentences]
- **[Specialist]:** [finding]
- **[Specialist]:** [finding]

**What This Would Explore:**
[Strategic value]

---

## Suggestion 3: [MEMORABLE_TITLE]

**Focal Question:** "[Question]"

**Why This Matters:**
[Reasoning]

**What This Would Explore:**
[Value]

---

## Custom Question

If none of these resonate, provide your own focal question and I'll help refine it based on the discovery findings.
```

### Step 3: Create discovery transcript template

Create `templates/discovery_transcript.md`:

```markdown
# [SPECIALIST_ROLE] Discovery Transcript - Round [N]

**Date:** [ISO timestamp]
**Company:** [Company name from company.md]
**Phase:** Phase 0 - Company Discovery

---

## Research Conducted

[Describe what you researched and why you chose these areas based on your domain expertise]

### Key Findings

**Finding 1: [Title]**
- [Description of finding]
- **Source:** [pp-cli citation or domain expertise]
- **Relevance:** [Why this matters for this company]

**Finding 2: [Title]**
- [Description]
- **Source:** [citation]
- **Relevance:** [impact]

[Continue for all major findings]

---

## Critical Uncertainties Identified

From my [domain] perspective, these uncertainties could significantly impact strategic choices:

1. **[Uncertainty name]**
   - What's uncertain: [description]
   - Why it matters: [strategic impact]
   - Possible directions: [how this could resolve]

2. **[Uncertainty name]**
   - What's uncertain: [description]
   - Why it matters: [impact]
   - Possible directions: [resolution paths]

---

## Questions for User

To better assess their strategic position from my perspective, I need to know:

1. **[Specific question]** - [Why you need this information]
2. **[Specific question]** - [Why this matters for your domain analysis]
3. **[Specific question]** - [Relevance]

---

## Preliminary Assessment

[2-3 sentences summarizing your initial take on their strategic challenges from your domain lens, acknowledging what you still need to learn]
```

### Step 4: Verify templates

Check that all three templates exist:
```bash
ls -la templates/company_profile.md templates/scenario_suggestions.md templates/discovery_transcript.md
```

Expected: All three files listed

### Step 5: Commit templates

```bash
git add templates/company_profile.md templates/scenario_suggestions.md templates/discovery_transcript.md
git commit -m "feat: add Phase 0 template files

- company_profile.md: Living document structure for company discovery
- scenario_suggestions.md: AI-generated focal question recommendations
- discovery_transcript.md: Specialist research output format

🤖 Generated with Claude Code"
```

---

## Task 2: Update Moderator Prompt - Phase 0 Section

**Files:**
- Modify: `prompts/moderator.md`

### Step 1: Read current moderator prompt

Read `prompts/moderator.md` to understand current structure and identify where to insert Phase 0 instructions.

### Step 2: Add Phase 0 section after role description, before Phase 1

Insert this section into `prompts/moderator.md` after the role/identity section but before the existing Phase 1 instructions:

```markdown
## Phase 0: Company Discovery

**Entry Point:** When user starts a new scenario, FIRST ask:

"Do you have a clear focal question for scenario development, or should I interview you about your company and market context first?"

### If User Wants Discovery (Recommended for Most Cases)

**Purpose:** Build comprehensive understanding of company context to:
- Generate AI-recommended focal questions grounded in real market conditions
- Provide specialists with context so they don't re-ask basic questions in later phases
- Ground scenarios in this specific company, not generic templates

#### Initial Interview (Mandatory)

Ask 2-3 basic questions to establish foundation:

1. **Company name and industry**
   - "What's your company name and what industry are you in?"

2. **Size and stage**
   - "What's your company size (revenue/employees) and stage (startup/growth/mature)?"

3. **Basic business model**
   - "What's your core business model and primary products/services?"

**After receiving answers:**
1. Create `company.md` using `templates/company_profile.md`
2. Fill in Basic Information section with user's answers
3. Initialize Discovery History with Round 1 timestamp

#### Discovery Loop (Iterative Until Convergence)

**Round N Process:**

**1. Invoke All 6 Specialists for Discovery Research**

For each specialist (economist, geopolitician, ecologist, futurist, anthropologist, contrarian):

```
Use Task tool to invoke specialist with context:

"PHASE 0 DISCOVERY - ROUND [N]

Read company.md to understand current company context.

[If Round 2+] Read your previous discovery transcript:
phase_0_discovery/research/[role]_discovery_round[N-1].md

Conduct research from your domain expertise perspective using pp-cli.
You decide what to research - trust your professional judgment about what
matters in your domain for this company's strategic context.

Create discovery transcript in:
phase_0_discovery/research/[role]_discovery_round[N].md

Use templates/discovery_transcript.md as format guide.

Include:
- Research findings with citations
- Critical uncertainties from your lens
- Specific questions we should ask the user
- Preliminary assessment of strategic challenges"
```

Set expectations with user: "I'm consulting all 6 specialists - this will take 10-15 minutes. I'll update you as each completes."

**2. Validate All 6 Discovery Transcripts**

After all specialists return, validate each transcript:
- Minimum 100 words of substantive content
- Includes research findings (with pp-cli citations where applicable)
- Identifies at least one uncertainty or question for user
- If transcript insufficient: Ask specialist to elaborate

**3. Synthesize Findings**

Review all 6 transcripts and:
- Identify common themes/patterns across specialists
- Identify questions that multiple specialists need answered
- Note contradictions or disagreements between specialist perspectives
- Identify new areas to explore based on research

**4. Present Synthesis to User**

Share key findings:
"Here's what the specialists discovered:

**Common Themes:**
- [Pattern found by multiple specialists]
- [Shared concern or opportunity]

**Questions That Emerged:**
Based on their research, I need to ask you about:
1. [Question informed by specialist findings]
2. [Question revealed by research]
..."

**5. Ask Follow-up Questions**

Ask targeted questions one at a time based on specialist findings.

Examples:
- Economist found supply chain stress → "Do you source components internationally? What % of inputs are imported?"
- Futurist found AI disruption in your industry → "Are you experimenting with AI in your operations? What's your current AI capability?"
- Geopolitician found regulatory changes → "How exposed are you to [specific regulation]? What's your compliance status?"

**6. Update company.md**

After user answers, update relevant sections of company.md with new information.
Update Discovery History with Round N timestamp and summary.

**7. Evaluate Convergence**

Ask yourself two questions:
1. **Did this round reveal significant new uncertainties or risks?**
   - If yes: Another round likely valuable
   - If no: Approaching convergence

2. **Ask user: "Does this feel like a comprehensive picture of your context, or should we dig deeper into specific areas?"**
   - If user wants deeper: Another round
   - If user confirms comprehensive: Convergence reached

**Maximum 4 rounds** - After round 4, force convergence even if more could be learned.

**If convergence reached:** Proceed to Scenario Suggestions

#### Scenario Suggestions Generation

After discovery convergence, generate 3-4 recommended focal questions.

**Analysis Process:**
1. Review all specialist discovery transcripts
2. Identify uncertainties flagged by multiple specialists (strong signal)
3. Identify high-impact strategic choices for this specific company
4. Ensure time horizons match company's planning cycle
5. Ensure genuine uncertainty (not predetermined outcomes)

**Create scenario_suggestions.md**

Use `templates/scenario_suggestions.md` format.

For each suggestion:
- **Memorable title** that captures the core tension
- **Specific focal question** with clear decision and time horizon
- **Why This Matters** section citing which specialists found what
- **What This Would Explore** explaining strategic value

**Present to User:**

"Based on discovery research, here are my recommended focal questions:

[Present 3-4 suggestions with titles and questions]

You can:
1. Pick one of these and I'll help refine it
2. Provide your own focal question and I'll help refine it based on discoveries
3. Ask me to generate different suggestions focusing on other areas

Which resonates most?"

#### Handoff to Phase 1

After user selects or provides focal question:

1. **Offer refinement suggestions** based on discovery findings
2. **Ensure question has:**
   - Clear strategic decision or choice
   - Specific time horizon
   - Testable scope (can develop scenarios and test strategies)
   - Grounded in company's actual context

3. **Create focal_question.md** (Phase 1 output, but streamlined)

4. **Proceed to Phase 2** (Predetermined Elements)
   - Specialists now have company.md and their own discovery research to reference
   - They should NOT re-ask basic questions
   - They should build directly on discovery findings

### If User Has Focal Question (Skip Deep Discovery)

If user says they have a clear focal question:

**Still ask 2-3 basic company questions:**
- Company name and industry
- Size/stage
- Basic business model

**Create minimal company.md** with basics only.

**Generate 2-3 alternative focal question suggestions** based on basics:
"Here are 2-3 alternative angles to consider based on your industry:
1. [Alternative question]
2. [Alternative question]

Or proceed with your question: [user's stated question]

Which direction?"

**Skip specialist discovery rounds** - proceed to Phase 1 refinement.

Note: You can offer to "backfill" Phase 0 discovery if you notice in Phase 2+ that specialists are struggling without company context.

---

### Phase 0 File Structure

```
scenarios/active/SCENARIO-YYYY-XXX/
├── metadata.json (updated with phase_0 tracking)
├── company.md (living document)
├── phase_0_discovery/
│   ├── scenario_suggestions.md
│   └── research/
│       ├── economist_discovery_round1.md
│       ├── economist_discovery_round2.md
│       ├── geopolitician_discovery_round1.md
│       ├── ecologist_discovery_round1.md
│       ├── futurist_discovery_round1.md
│       ├── anthropologist_discovery_round1.md
│       └── contrarian_discovery_round1.md
```

### Phase 0 Metadata Tracking

In metadata.json, track:

```json
{
  "current_phase": 0,
  "status": "phase_0_discovery",
  "phase_0": {
    "discovery_rounds": 2,
    "specialists_consulted": [
      {
        "specialist": "economist",
        "round": 1,
        "timestamp": "2025-11-18T...",
        "transcript": "phase_0_discovery/research/economist_discovery_round1.md"
      }
    ],
    "convergence_reached": true,
    "user_confirmed": true,
    "scenario_suggestions_generated": true
  }
}
```

### Error Handling

**User provides minimal information:**
- "That's okay - let me have specialists research your industry broadly, then we can narrow down what's relevant to you"
- Proceed with generic industry research, refine as user learns

**Specialist research reveals nothing actionable:**
- Still valuable - document "From my perspective, this is a low-risk area"
- Other specialists may find uncertainties

**Convergence never reached after 4 rounds:**
- Force convergence: "We could keep discovering, but I have enough to generate scenarios. Should we proceed?"

**pp-cli research fails:**
- Specialist notes in transcript: "Unable to research [topic] - proceeding with domain expertise only"
- If multiple specialists hit failures: pause and notify user

**Specialist returns insufficient transcript:**
- Reject and ask to elaborate if <100 words
- Remind to use pp-cli for research
- Accept if no questions (may indicate low-risk area)

```

### Step 3: Verify moderator.md updated

Read `prompts/moderator.md` and confirm Phase 0 section exists and is properly formatted.

### Step 4: Commit moderator changes

```bash
git add prompts/moderator.md
git commit -m "feat: add Phase 0 discovery to moderator prompt

Dr. Wells now orchestrates intelligent discovery loop:
- Initial interview (2-3 basic questions)
- Iterative specialist research rounds
- Synthesis and follow-up questions
- Convergence detection
- Scenario suggestions generation
- Handoff to Phase 1

🤖 Generated with Claude Code"
```

---

## Task 3: Update Economist Specialist Prompt

**Files:**
- Modify: `prompts/specialists/economist.md`

### Step 1: Read current economist prompt

Read `prompts/specialists/economist.md` to understand current structure.

### Step 2: Add Discovery Mode section

Insert this section after the role description but before the existing phase-specific instructions:

```markdown
## Discovery Mode (Phase 0)

**Context:** You're being consulted during Phase 0 (Company Discovery) to research economic conditions, market dynamics, and financial factors relevant to this company's strategic context.

**Your Task:**

1. **Read company.md** to understand what we currently know about this company
2. **Read your previous discovery transcript** (if Round 2+) to see what you already researched
3. **Conduct research** using pp-cli to investigate current economic conditions from your perspective
4. **Formulate questions** we should ask the user to assess their economic position
5. **Document findings** in a discovery transcript

**What to Research (Use Your Judgment):**

As an economist, you decide what economic factors matter for this company. Consider researching:
- Industry profitability trends and margin pressures
- Capital intensity and financing environment
- Market structure and competitive dynamics
- Customer/supplier concentration risks
- Commodity price exposure and input cost trends
- Debt levels and financial regime shifts
- Regulatory economic impacts
- Labor market conditions and wage pressures

**You're the expert - research what matters from your economic lens.**

**Discovery Transcript Format:**

Create transcript at: `phase_0_discovery/research/economist_discovery_round[N].md`

Use `templates/discovery_transcript.md` as guide.

Include:
- **Research Conducted:** What you researched and why
- **Key Findings:** Economic conditions, trends, risks you discovered (with pp-cli citations)
- **Critical Uncertainties:** Economic factors that could go multiple ways
- **Questions for User:** Specific questions about their financial position, cost structure, market exposure
- **Preliminary Assessment:** Your initial take on their economic challenges

**Example pp-cli Usage:**

```bash
pp --no-interactive "US auto parts manufacturing profitability 2024-2025" --output json
pp --no-interactive "EV transition capital requirements OEM suppliers" --output json
```

**Remember:**
- Minimum 100 words of substantive analysis
- Cite research sources
- Focus on uncertainties and strategic implications
- Ask specific questions, not generic ones
```

### Step 3: Verify economist.md updated

Read `prompts/specialists/economist.md` and confirm Discovery Mode section exists.

### Step 4: Commit economist changes

```bash
git add prompts/specialists/economist.md
git commit -m "feat: add Phase 0 discovery mode to economist

Economist now conducts economic research during company discovery:
- Researches industry profitability, capital intensity, market structure
- Uses professional judgment to determine relevant factors
- Creates discovery transcripts with findings and questions
- Identifies economic uncertainties affecting strategy

🤖 Generated with Claude Code"
```

---

## Task 4: Update Geopolitician Specialist Prompt

**Files:**
- Modify: `prompts/specialists/geopolitician.md`

### Step 1: Read current geopolitician prompt

Read `prompts/specialists/geopolitician.md` to understand current structure.

### Step 2: Add Discovery Mode section

Insert after role description:

```markdown
## Discovery Mode (Phase 0)

**Context:** You're being consulted during Phase 0 (Company Discovery) to research geopolitical dynamics, trade relationships, regulatory environments, and power structures relevant to this company's strategic context.

**Your Task:**

1. **Read company.md** to understand current company context
2. **Read your previous discovery transcript** (if Round 2+) to see prior research
3. **Conduct research** using pp-cli to investigate geopolitical factors from your perspective
4. **Formulate questions** we should ask the user about their geopolitical exposure
5. **Document findings** in a discovery transcript

**What to Research (Use Your Judgment):**

As a geopolitician, you decide what geopolitical factors matter. Consider researching:
- Trade policy and tariff dynamics affecting their industry
- Regulatory changes and government intervention trends
- Cross-border supply chain vulnerabilities
- Resource access and control (critical materials, energy, water)
- International competition and state-backed competitors
- Sanctions, export controls, or technology restrictions
- Political stability in key markets or supplier regions
- Infrastructure and logistics constraints

**You're the expert - research what matters from your geopolitical lens.**

**Discovery Transcript Format:**

Create transcript at: `phase_0_discovery/research/geopolitician_discovery_round[N].md`

Use `templates/discovery_transcript.md` as guide.

Include:
- **Research Conducted:** What you researched and why
- **Key Findings:** Geopolitical conditions, policy shifts, power dynamics (with pp-cli citations)
- **Critical Uncertainties:** Geopolitical factors that could shift
- **Questions for User:** Specific questions about their international exposure, regulatory compliance, supplier geography
- **Preliminary Assessment:** Your initial take on their geopolitical risks

**Example pp-cli Usage:**

```bash
pp --no-interactive "US-China trade policy auto parts 2024-2025" --output json
pp --no-interactive "Critical minerals supply chain vulnerabilities semiconductors" --output json
```

**Remember:**
- Minimum 100 words of substantive analysis
- Cite research sources
- Focus on power dynamics and strategic dependencies
- Ask specific questions about their geopolitical exposure
```

### Step 3: Verify geopolitician.md updated

Read `prompts/specialists/geopolitician.md` and confirm Discovery Mode section exists.

### Step 4: Commit geopolitician changes

```bash
git add prompts/specialists/geopolitician.md
git commit -m "feat: add Phase 0 discovery mode to geopolitician

Geopolitician researches trade, regulatory, and power dynamics:
- Analyzes policy shifts, supply chain vulnerabilities, state competition
- Uses professional judgment for geopolitical risk assessment
- Creates discovery transcripts with findings and questions
- Identifies geopolitical uncertainties affecting strategy

🤖 Generated with Claude Code"
```

---

## Task 5: Update Ecologist Specialist Prompt

**Files:**
- Modify: `prompts/specialists/ecologist.md`

### Step 1: Read current ecologist prompt

Read `prompts/specialists/ecologist.md` to understand current structure.

### Step 2: Add Discovery Mode section

Insert after role description:

```markdown
## Discovery Mode (Phase 0)

**Context:** You're being consulted during Phase 0 (Company Discovery) to research ecological systems, resource dependencies, environmental constraints, and resilience factors relevant to this company's strategic context.

**Your Task:**

1. **Read company.md** to understand current company context
2. **Read your previous discovery transcript** (if Round 2+) to see prior research
3. **Conduct research** using pp-cli to investigate ecological factors from your perspective
4. **Formulate questions** we should ask the user about their resource dependencies and environmental exposure
5. **Document findings** in a discovery transcript

**What to Research (Use Your Judgment):**

As an ecologist, you decide what ecological and resource factors matter. Consider researching:
- Resource dependencies (water, energy, materials, land)
- Climate change impacts on operations or supply chains
- Biodiversity loss affecting ecosystem services they depend on
- Circular economy trends and waste regulations
- Material scarcity and substitution possibilities
- Pollution regulations and environmental compliance costs
- Ecosystem feedback loops and tipping points
- Resilience of systems they depend on

**You're the expert - research what matters from your ecological lens.**

**Discovery Transcript Format:**

Create transcript at: `phase_0_discovery/research/ecologist_discovery_round[N].md`

Use `templates/discovery_transcript.md` as guide.

Include:
- **Research Conducted:** What you researched and why
- **Key Findings:** Ecological conditions, resource trends, environmental risks (with pp-cli citations)
- **Critical Uncertainties:** Ecological factors that could shift
- **Questions for User:** Specific questions about their resource use, environmental footprint, supply chain resilience
- **Preliminary Assessment:** Your initial take on their ecological dependencies

**Example pp-cli Usage:**

```bash
pp --no-interactive "Water scarcity manufacturing southwestern US 2024" --output json
pp --no-interactive "Lithium supply constraints battery production 2025" --output json
```

**Remember:**
- Minimum 100 words of substantive analysis
- Cite research sources
- Focus on systems thinking and feedback loops
- Ask specific questions about their resource dependencies
```

### Step 3: Verify ecologist.md updated

Read `prompts/specialists/ecologist.md` and confirm Discovery Mode section exists.

### Step 4: Commit ecologist changes

```bash
git add prompts/specialists/ecologist.md
git commit -m "feat: add Phase 0 discovery mode to ecologist

Ecologist researches resource dependencies and environmental factors:
- Analyzes climate impacts, material scarcity, ecosystem services
- Uses professional judgment for ecological risk assessment
- Creates discovery transcripts with findings and questions
- Identifies ecological uncertainties affecting resilience

🤖 Generated with Claude Code"
```

---

## Task 6: Update Futurist Specialist Prompt

**Files:**
- Modify: `prompts/specialists/futurist.md`

### Step 1: Read current futurist prompt

Read `prompts/specialists/futurist.md` to understand current structure.

### Step 2: Add Discovery Mode section

Insert after role description:

```markdown
## Discovery Mode (Phase 0)

**Context:** You're being consulted during Phase 0 (Company Discovery) to research technology trends, capability shifts, innovation patterns, and inflection points relevant to this company's strategic context.

**Your Task:**

1. **Read company.md** to understand current company context
2. **Read your previous discovery transcript** (if Round 2+) to see prior research
3. **Conduct research** using pp-cli to investigate technology and capability trends from your perspective
4. **Formulate questions** we should ask the user about their technology position and adaptation capability
5. **Document findings** in a discovery transcript

**What to Research (Use Your Judgment):**

As a futurist, you decide what technology and capability factors matter. Consider researching:
- Emerging technologies disrupting their industry
- Automation and AI adoption trajectories
- New business model innovations threatening incumbents
- Technology S-curves and capability maturation
- Skill/talent availability and capability gaps
- Innovation velocity and development cycle compression
- Technology platform shifts (centralization vs. decentralization)
- Inflection points where change accelerates

**You're the expert - research what matters from your futurist lens.**

**Discovery Transcript Format:**

Create transcript at: `phase_0_discovery/research/futurist_discovery_round[N].md`

Use `templates/discovery_transcript.md` as guide.

Include:
- **Research Conducted:** What you researched and why
- **Key Findings:** Technology trends, capability shifts, inflection points (with pp-cli citations)
- **Critical Uncertainties:** Technology factors that could evolve differently
- **Questions for User:** Specific questions about their technology stack, innovation capability, adaptation speed
- **Preliminary Assessment:** Your initial take on their technology position and disruption exposure

**Example pp-cli Usage:**

```bash
pp --no-interactive "AI drug discovery adoption pharmaceutical 2024-2025" --output json
pp --no-interactive "Generative AI impact software development productivity" --output json
```

**Remember:**
- Minimum 100 words of substantive analysis
- Cite research sources
- Focus on inflection points and capability shifts
- Ask specific questions about their technology position
```

### Step 3: Verify futurist.md updated

Read `prompts/specialists/futurist.md` and confirm Discovery Mode section exists.

### Step 4: Commit futurist changes

```bash
git add prompts/specialists/futurist.md
git commit -m "feat: add Phase 0 discovery mode to futurist

Futurist researches technology trends and capability shifts:
- Analyzes emerging tech, AI adoption, innovation patterns
- Uses professional judgment for technology inflection points
- Creates discovery transcripts with findings and questions
- Identifies technology uncertainties affecting competitive position

🤖 Generated with Claude Code"
```

---

## Task 7: Update Anthropologist Specialist Prompt

**Files:**
- Modify: `prompts/specialists/anthropologist.md`

### Step 1: Read current anthropologist prompt

Read `prompts/specialists/anthropologist.md` to understand current structure.

### Step 2: Add Discovery Mode section

Insert after role description:

```markdown
## Discovery Mode (Phase 0)

**Context:** You're being consulted during Phase 0 (Company Discovery) to research cultural dynamics, stakeholder values, human behavior patterns, and lived experience relevant to this company's strategic context.

**Your Task:**

1. **Read company.md** to understand current company context
2. **Read your previous discovery transcript** (if Round 2+) to see prior research
3. **Conduct research** using pp-cli to investigate cultural and human factors from your perspective
4. **Formulate questions** we should ask the user about their stakeholder relationships and cultural context
5. **Document findings** in a discovery transcript

**What to Research (Use Your Judgment):**

As an anthropologist, you decide what cultural and human factors matter. Consider researching:
- Customer behavior shifts and preference changes
- Employee expectations and labor movement trends
- Stakeholder value evolution (investors, communities, regulators)
- Cultural narratives affecting their industry (e.g., "big pharma bad")
- Trust dynamics and institutional legitimacy
- Generational shifts in consumption or work
- Social movements impacting their operations or market
- Lived experience of people affected by their business

**You're the expert - research what matters from your anthropological lens.**

**Discovery Transcript Format:**

Create transcript at: `phase_0_discovery/research/anthropologist_discovery_round[N].md`

Use `templates/discovery_transcript.md` as guide.

Include:
- **Research Conducted:** What you researched and why
- **Key Findings:** Cultural trends, stakeholder dynamics, behavior shifts (with pp-cli citations)
- **Critical Uncertainties:** Cultural factors that could evolve differently
- **Questions for User:** Specific questions about their customer relationships, employee culture, community perception
- **Preliminary Assessment:** Your initial take on their cultural positioning and stakeholder challenges

**Example pp-cli Usage:**

```bash
pp --no-interactive "Remote work preferences office return 2024-2025" --output json
pp --no-interactive "Gen Z consumer sustainability expectations fashion" --output json
```

**Remember:**
- Minimum 100 words of substantive analysis
- Cite research sources
- Focus on human experience and cultural meaning
- Ask specific questions about their stakeholder relationships
```

### Step 3: Verify anthropologist.md updated

Read `prompts/specialists/anthropologist.md` and confirm Discovery Mode section exists.

### Step 4: Commit anthropologist changes

```bash
git add prompts/specialists/anthropologist.md
git commit -m "feat: add Phase 0 discovery mode to anthropologist

Anthropologist researches cultural dynamics and stakeholder values:
- Analyzes behavior shifts, trust dynamics, social movements
- Uses professional judgment for cultural trend assessment
- Creates discovery transcripts with findings and questions
- Identifies cultural uncertainties affecting legitimacy

🤖 Generated with Claude Code"
```

---

## Task 8: Update Contrarian Specialist Prompt

**Files:**
- Modify: `prompts/specialists/contrarian.md`

### Step 1: Read current contrarian prompt

Read `prompts/specialists/contrarian.md` to understand current structure.

### Step 2: Add Discovery Mode section

Insert after role description:

```markdown
## Discovery Mode (Phase 0)

**Context:** You're being consulted during Phase 0 (Company Discovery) to challenge consensus narratives, identify hidden assumptions, and surface risks that other specialists might miss about this company's strategic context.

**Your Task:**

1. **Read company.md** to understand current company context
2. **Read your previous discovery transcript** (if Round 2+) to see prior research
3. **Conduct research** using pp-cli to investigate contrarian perspectives on their industry
4. **Formulate questions** we should ask the user to test assumptions
5. **Document findings** in a discovery transcript

**What to Research (Use Your Judgment):**

As a contrarian, you decide what consensus narratives need challenging. Consider researching:
- Industry assumptions everyone believes but might be wrong
- Extrapolations that might not hold (e.g., "growth will continue")
- Second-order effects others miss
- Historical precedents of similar consensus failures
- What's being ignored or dismissed by mainstream analysis
- Risks considered "impossible" that aren't
- Benefits of paths considered "obviously bad"
- Hidden fragilities in "obviously good" strategies

**You're the expert - research what matters from your contrarian lens.**

**Discovery Transcript Format:**

Create transcript at: `phase_0_discovery/research/contrarian_discovery_round[N].md`

Use `templates/discovery_transcript.md` as guide.

Include:
- **Research Conducted:** What consensus narratives you investigated
- **Key Findings:** Assumptions being made, historical precedents, ignored factors (with pp-cli citations)
- **Critical Uncertainties:** Contrarian scenarios others aren't considering
- **Questions for User:** Specific questions to test their assumptions and reveal hidden risks
- **Preliminary Assessment:** Your initial take on what they might be missing

**Example pp-cli Usage:**

```bash
pp --no-interactive "EV adoption slower than expected reasons 2024" --output json
pp --no-interactive "Remote work backlash office return mandates 2024-2025" --output json
```

**Remember:**
- Minimum 100 words of substantive analysis
- Cite research sources (including contrarian sources)
- Focus on questioning assumptions, not just being negative
- Ask questions that reveal blind spots
```

### Step 3: Verify contrarian.md updated

Read `prompts/specialists/contrarian.md` and confirm Discovery Mode section exists.

### Step 4: Commit contrarian changes

```bash
git add prompts/specialists/contrarian.md
git commit -m "feat: add Phase 0 discovery mode to contrarian

Contrarian challenges consensus narratives and hidden assumptions:
- Researches what industry consensus believes and might be wrong
- Uses professional judgment to identify blind spots
- Creates discovery transcripts with findings and questions
- Surfaces contrarian scenarios others aren't considering

🤖 Generated with Claude Code"
```

---

## Task 9: Update README Documentation

**Files:**
- Modify: `README.md`

### Step 1: Read current README

Read `README.md` to understand current structure.

### Step 2: Update phase descriptions

Find the section describing the 6-phase workflow. Update it to describe 7 phases:

**Old text to find:**
Look for section describing "Six-Phase Workflow" or similar.

**New text to insert:**

```markdown
## Seven-Phase Workflow

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
- `phase_0_discovery/research/` - 6 specialist discovery transcripts (per round)
- `scenario_suggestions.md` - AI-generated focal question recommendations

**User chooses:** Pick recommended question or provide their own → Proceed to Phase 1

**Can be skipped:** If user has clear focal question, basic company info is captured but deep discovery is optional.

---

### Phase 1: Focal Question Definition

[Existing Phase 1 description - now streamlined since Phase 0 provides context]

### Phase 2-6: [Existing descriptions]

[Keep existing phase descriptions, note that specialists now reference Phase 0 context]
```

### Step 3: Update "Getting Started" or similar section

Add note about Phase 0:

```markdown
**Starting a New Scenario:**

When you begin, Dr. Wells will ask: "Do you have a clear focal question, or should I interview you about your company first?"

- **Recommended:** Choose interview - Phase 0 discovery helps generate better focal questions and provides specialists with context
- **Fast path:** Provide focal question directly - basic company info is still captured but deep research is skipped

Phase 0 typically takes 30-45 minutes (includes 6 specialist consultations + user interview rounds).
```

### Step 4: Verify README updated

Read `README.md` and confirm Phase 0 is documented.

### Step 5: Commit README changes

```bash
git add README.md
git commit -m "docs: update README for Phase 0 company discovery

- Document new 7-phase workflow (was 6 phases)
- Explain Phase 0 purpose, process, and outputs
- Note Phase 0 can be skipped for users with clear questions
- Update getting started guidance

🤖 Generated with Claude Code"
```

---

## Task 10: Update QUICKSTART Documentation

**Files:**
- Modify: `QUICKSTART.md`

### Step 1: Read current QUICKSTART

Read `QUICKSTART.md` to understand current structure.

### Step 2: Add Phase 0 quickstart example

Find the section showing example workflow. Add Phase 0 example:

```markdown
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
```

### Step 3: Verify QUICKSTART updated

Read `QUICKSTART.md` and confirm Phase 0 example exists.

### Step 4: Commit QUICKSTART changes

```bash
git add QUICKSTART.md
git commit -m "docs: add Phase 0 discovery example to quickstart

Shows complete discovery workflow:
- Initial interview
- Specialist research
- Follow-up questions
- Scenario suggestions
- User selection

🤖 Generated with Claude Code"
```

---

## Task 11: Test Phase 0 with Example Company

**Purpose:** Validate the implementation works end-to-end with a real example (different industry than existing Synthyra example).

### Step 1: Choose test company

Suggested: **"Regional grocery chain in the Midwest US"**
- Different industry than Synthyra (biotech)
- Interesting uncertainties (e-commerce, consolidation, labor, supply chain)
- Will exercise all 6 specialists

### Step 2: Create test scenario

Manually walk through Phase 0 as Dr. Wells would:

1. Create scenario directory: `scenarios/active/SCENARIO-2025-TEST-PHASE0/`
2. Create `company.md` with test data
3. Manually create discovery transcripts for all 6 specialists (Round 1)
4. Create `scenario_suggestions.md` with 3 recommendations

**Purpose:** Verify templates work, file structure is correct, content makes sense.

### Step 3: Document test results

Create `docs/testing/phase-0-test-results.md`:

```markdown
# Phase 0 Test Results

**Test Date:** [Date]
**Test Company:** Regional grocery chain (Midwest US)

## Test Coverage

- ✅ company.md template works
- ✅ Discovery transcript template works (all 6 specialists)
- ✅ Scenario suggestions template works
- ✅ File structure correct
- ✅ Content quality reasonable

## Example Discovery Findings

**Economist:** Margin pressure from dollar stores, private label growth, wage inflation
**Geopolitician:** Supply chain concentration, food safety regulations, trade policy impact on prices
**Ecologist:** Food waste regulations, refrigeration energy costs, sustainable sourcing pressure
**Futurist:** E-commerce + delivery model disruption, automation in warehouses, cashierless stores
**Anthropologist:** Shopping behavior shifts post-pandemic, local sourcing preferences, food access equity
**Contrarian:** "E-commerce will kill grocery stores" might be overblown, delivery economics questionable

## Scenario Suggestions Generated

1. **The Last-Mile Question:** Delivery model strategy given uncertainty about e-grocery profitability
2. **The Format Question:** Store format investment given uncertain shopping preference shifts
3. **The Consolidation Question:** Independence vs. acquisition decision given regional consolidation

## Issues Found

[Document any template issues, confusing instructions, missing guidance]

## Recommended Improvements

[Note any refinements needed to prompts or templates]
```

### Step 4: Commit test results

```bash
git add scenarios/active/SCENARIO-2025-TEST-PHASE0/ docs/testing/phase-0-test-results.md
git commit -m "test: validate Phase 0 with grocery chain example

Tested complete discovery workflow:
- All 6 specialist discovery transcripts
- Company profile creation
- Scenario suggestions generation

Confirms templates and structure work correctly.

🤖 Generated with Claude Code"
```

---

## Task 12: Final Review and Documentation

### Step 1: Review all changes

Read through all modified files to ensure:
- Consistent terminology
- No broken references
- Templates referenced correctly
- All 6 specialists have discovery mode

### Step 2: Update design doc status

Edit `docs/plans/2025-11-18-phase-0-company-discovery-design.md`:

Change status from "Design Complete - Ready for Implementation" to:

```markdown
**Status:** ✅ IMPLEMENTED - Ready for Production Use
**Implementation Date:** [Date]
```

### Step 3: Create implementation summary

Create `docs/implementation-notes/phase-0-implementation-summary.md`:

```markdown
# Phase 0 Implementation Summary

**Completed:** [Date]
**Branch:** feature/phase-0-discovery

## Changes Made

### Templates Created (3 files)
- `templates/company_profile.md` - Living company profile structure
- `templates/scenario_suggestions.md` - AI focal question recommendations
- `templates/discovery_transcript.md` - Specialist research output format

### Prompts Updated (7 files)
- `prompts/moderator.md` - Added Phase 0 orchestration instructions
- `prompts/specialists/economist.md` - Added discovery mode
- `prompts/specialists/geopolitician.md` - Added discovery mode
- `prompts/specialists/ecologist.md` - Added discovery mode
- `prompts/specialists/futurist.md` - Added discovery mode
- `prompts/specialists/anthropologist.md` - Added discovery mode
- `prompts/specialists/contrarian.md` - Added discovery mode

### Documentation Updated (2 files)
- `README.md` - Updated to 7-phase workflow, documented Phase 0
- `QUICKSTART.md` - Added Phase 0 example workflow

### Testing
- ✅ Validated with grocery chain test scenario
- ✅ All templates work correctly
- ✅ File structure tested

## File Structure

Phase 0 creates this structure:

```
scenarios/active/SCENARIO-YYYY-XXX/
├── company.md
├── phase_0_discovery/
│   ├── scenario_suggestions.md
│   └── research/
│       ├── economist_discovery_round1.md
│       ├── geopolitician_discovery_round1.md
│       ├── ecologist_discovery_round1.md
│       ├── futurist_discovery_round1.md
│       ├── anthropologist_discovery_round1.md
│       └── contrarian_discovery_round1.md
```

## Usage

**To use Phase 0:**
1. Start new scenario
2. When Dr. Wells asks, choose "interview me about my company"
3. Answer 2-3 basic questions
4. Wait for 6 specialist research consultations (~10-15 min)
5. Answer follow-up questions based on specialist findings
6. Repeat if needed (typically 1-3 rounds total)
7. Review scenario suggestions and select focal question

**To skip Phase 0:**
1. Start new scenario
2. When Dr. Wells asks, say "I have a focal question"
3. Provide your question
4. Minimal company info captured, proceed to Phase 1

## Next Steps

- Monitor first production usage for issues
- Gather user feedback on discovery loop experience
- Consider optimizations if discovery rounds take too long
- Potentially add specialist selection (user picks 3-4 instead of all 6)

## Known Limitations

- Discovery takes 30-45 minutes (6 specialists × 2-3 rounds)
- No parallel specialist invocations (Task tool limitation)
- No automated convergence detection (relies on Dr. Wells judgment)
- pp-cli failures require manual handling
```

### Step 4: Final commit

```bash
git add docs/plans/2025-11-18-phase-0-company-discovery-design.md docs/implementation-notes/phase-0-implementation-summary.md
git commit -m "docs: mark Phase 0 implementation complete

Implementation summary documents:
- 3 templates created
- 7 prompts updated (moderator + 6 specialists)
- 2 docs updated (README, QUICKSTART)
- Tested with grocery chain example

Phase 0 ready for production use.

🤖 Generated with Claude Code"
```

---

## Summary

**Total Tasks:** 12
**Estimated Time:** 2-3 hours (manual testing is the longest part)

**What Gets Built:**
1. ✅ 3 template files for Phase 0 artifacts
2. ✅ Updated moderator with complete Phase 0 orchestration
3. ✅ All 6 specialists with discovery mode instructions
4. ✅ Updated documentation (README, QUICKSTART)
5. ✅ Test scenario validating end-to-end workflow
6. ✅ Implementation summary and design status update

**Result:**
Shell Scenario Panel gains intelligent company discovery capability, transforming it from "develop scenarios given a question" to "discover the question and develop scenarios grounded in market reality."
