# Impact Layer Architecture Design for Shell Scenario Panel

## Design Date: 2026-03-19

## Executive Summary

This design introduces a new **impact layer** downstream from external scenario analysis and upstream from recommendations. The goal is to preserve the Shell panel's strength in modeling the outside world while adding a rigorous, actor-relative translation step that answers:

- What does this mean for me?
- What should I prepare for?
- How does this affect my household, company, customers, or dependents?
- How should I position a product, make a decision, or monitor signals?

The central move is to separate:

- **External frame:** what is happening outside the actor
- **Impact:** how that external frame changes the actor's situation
- **Response:** what the actor should do, say, prepare, or monitor

This must work for both business and non-business contexts. A household is treated as a real system, not as an afterthought to a company model.

The impact layer also requires its own **multi-agent persona architecture**. The existing Shell specialists are primarily world-modelers. The new layer needs a permanent impact kernel, domain overlays, dynamic stakeholder seats, and permanent challenge/evidence roles such as a contrarian, precedent finder, and signal/data interpreter.

## Problem Statement

The current Shell Scenario Panel already contains several important ingredients:

- `worldview_model.md` captures how the user thinks
- `phase_0_discovery/internal_baseline.md` captures the user's base case and risk posture
- external scenario phases model the outside world
- `worldview_integration.md` maps scenarios back to beliefs

What is missing is an explicit translation step:

`external frame -> actor system -> consequences -> response`

Without that step, the system tends to blur:

- scenario logic
- impact on the actor
- strategic recommendation
- worldview reflection

This blur creates generic outputs, especially when the user asks questions such as:

- "What does this mean to me and what should I prepare for?"
- "Should I sell my gas car and move to an EV?"
- "Should I pay down debt faster if rates may rise?"
- "How might this affect my partner as a teacher or my daughters in college?"
- "How should we position our AI product for middle-market manufacturing clients?"

Those are not just scenario questions. They are impact questions.

## Core Definitions

### 1. External Frame

The outside-world object being reasoned over. This can be:

- the current situation
- a trend packet
- a specific shock or event
- a single scenario
- a full scenario set

The external frame should remain reusable and actor-agnostic.

### 2. Actor

The entity whose consequences matter. This is broader than "the user."

Examples:

- the user as an individual
- the household
- the user's significant other in a specific role
- a daughter in college
- the user's company
- the user's customer
- a buyer inside that customer

The correct unit is the **focal actor** or **actor graph**, not simply "the user."

### 3. Impact

How an external frame changes the goals, constraints, risks, options, timing, burdens, or payoffs of a specific actor.

Impact is actor-relative and query-relative.

### 4. Response

The answer mode requested by the user after impact has been understood.

Examples:

- meaning
- preparedness
- prioritization
- monitoring
- positioning
- decision support

### 5. Reflection

How the impact and response relate back to the user's worldview, base case, and cruxes.

## What Impact Is Not

Impact is not:

- a property of the scenario itself
- a substitute for recommendation
- a synonym for worldview integration
- limited to business strategy
- limited to a single actor

Scenario files should stay reusable across actors. Impact should not be baked into scenario narratives as if the same world has the same meaning for everyone.

## Design Principles

### 1. Actor-Relative, Not Business-Relative

The impact layer must work for:

- companies
- households
- families
- buyers
- institutions
- portfolio companies
- communities

A household is a system with:

- a balance sheet
- recurring routines
- institutional dependencies
- burden distribution
- dependents
- optionality constraints

### 2. Query-Driven, Not Only Phase-Driven

Impact should be available:

- as a formal phase after scenario work
- as an on-demand capability when the user asks direct meaning/preparedness/positioning questions

The same external frame may support multiple response modes.

### 3. Impact Before Recommendation

The system should not jump directly from external analysis to advice.

It should pass through:

`external frame -> transmission -> impact map -> response`

### 4. Preserve Baseline and Delta

Impact analysis should make explicit:

- what was true before
- what changed
- what is now more or less urgent, valuable, risky, or reversible

Without baseline and delta, the system becomes generic.

### 5. Multi-Actor Graphs Are First-Class

Some questions require more than one actor.

Example:

`external situation -> customer company -> buyer inside customer -> user company positioning`

This is essential for commercial questions and equally important in household questions.

### 6. Burden Distribution Matters

For household and institutional questions, the system must surface:

- who carries cost
- who carries inconvenience
- who carries uncertainty
- who carries implementation burden

The best move for one actor may create hidden burden for another.

### 7. Contrarian, Precedent, and Signal Roles Are Mandatory

As in the existing Shell panel, the impact layer must always include structured challenge and evidence interpretation.

The permanent cast must include:

- a contrarian
- a precedent-finder
- a signal/data-bricks interpreter

### 8. Persona Depth Must Match The Shell Panel

The impact layer should not be implemented as thin role labels or lightweight consultant archetypes.

The permanent and overlay personas should be authored with roughly the same degree of completeness as the existing Shell specialist prompts. This is not just for style consistency. It is a functional design requirement.

Deep persona authoring helps:

- anchor the agent in a specific reasoning mode
- preserve distinctive voice across repeated invocations
- surface characteristic blind spots rather than generic balance
- activate a more stable and specific latent frame
- prevent the panel from collapsing into interchangeable business advice

The goal is to achieve the same kind of strong lensing that the Shell panel gets from its current specialist prompts.

This means the impact personas should generally include:

- role identity and seat in the world
- origin story / formative experiences
- intellectual frameworks and terminology
- what they notice that others miss
- what they over-index on
- characteristic questions
- voice and communication style
- known biases and blind spots
- analytical approach

The impact cast may be somewhat less theatrical than the Shell cast, but it should not be materially thinner.

### 9. Personas Should Be Named Composite Humans

The impact cast should feel like real people with real names, real backgrounds, and real formative experiences.

These should generally be authored as **composite personas** based on realistic source material such as:

- public professional biographies
- LinkedIn-style career histories
- resumes / CVs
- internal character dossiers
- composite background notes built from multiple real-world profiles

This is preferable to anonymous labels like "Procurement Expert" or "Financial Analyst."

Reasons:

- real-seeming names and backgrounds help stabilize the persona's latent frame
- a grounded biography creates more durable voice, judgment, and bias
- composites can combine the right expertise without pretending to exactly imitate a living person
- the panel becomes more memorable and more internally coherent across repeated invocations

Design rule:

- permanent personas should usually have proper names
- their backgrounds should plausibly explain how they think
- their analytical style should emerge from biography, not from a role label alone

The target is not celebrity imitation. The target is **dossier-grade specificity**.

### 10. Persona Source Material Can Be Dossier-Driven

Where available, persona construction may be informed by dossier-like source material rather than only by prompt writing from scratch.

Useful source patterns include:

- personal dossiers
- voice guides
- prompt packs
- adversarial panel prompt systems
- background/reference packets for a single operator or thinker

This is relevant not just for modeling the user, but also for constructing strong composite panelists. A dossier-grade source packet provides a useful template for how much specificity the impact personas should carry.

## High-Level Architecture

The impact layer sits between external scenario work and recommendations.

### Analysis Flow

`Query Contract -> External Frame -> Actor Graph -> Transmission Map -> Impact Map -> Response Mode -> Reflection`

### Layer Meanings

#### Query Contract

Clarifies what the user actually wants.

Examples:

- "What does this mean to me?"
- "What should I prepare for?"
- "Should I make this purchase or hold off?"
- "How should we position this product?"

#### External Frame

The outside-world state or set of possible states.

#### Actor Graph

The relevant set of roles and relationships affected by the external frame.

#### Transmission Map

The channels through which the external frame reaches the actor.

Examples:

- prices
- rates
- credit conditions
- school budgets
- procurement friction
- trust
- commuting cost
- implementation burden
- energy supply
- labor market pressure

#### Impact Map

The actor-relative consequences.

Examples:

- what gets more expensive
- what gets harder
- what becomes more urgent
- what becomes politically risky
- what becomes valuable enough to pay for
- what becomes irreversible if delayed

#### Response Mode

The final answer mode. Not every query needs the same output.

#### Reflection

Optional reconciliation with worldview and baseline assumptions.

## Relationship To Existing Shell Specialists

The existing Shell specialists remain the primary **world-modeling cast**:

- ecologist
- geopolitician
- anthropologist
- futurist
- economist
- contrarian
- researcher
- quality analyst

They explain:

- what is changing outside
- why those changes matter structurally
- what scenario logic is plausible

They are not, by default, sufficient for actor-relative impact work.

The impact layer therefore requires a second cast architecture.

## Impact Persona Architecture

The impact layer should use four persona groups:

1. **Permanent impact kernel**
2. **Domain overlays**
3. **Dynamic stakeholder seats**
4. **Permanent challenge/evidence roles**

### 1. Permanent Impact Kernel

These roles should appear in most impact questions regardless of domain.

Implementation note:

Each permanent role below should ultimately be realized as a full prompt persona, not merely a routing label.

#### Ledger Keeper

Primary concern:
- cash flow, debt service, liquidity, affordability, budget thresholds

Best at surfacing:
- financial pressure
- rate sensitivity
- cost asymmetry
- budget timing

Questions:
- What line items move first?
- What becomes unaffordable or fragile?
- What is fixed versus adjustable?

#### Friction Mechanic

Primary concern:
- what becomes harder to do in everyday operations or routines

Best at surfacing:
- workflow friction
- implementation burden
- daily logistics
- hidden execution pain

Questions:
- What breaks on Monday morning?
- What gets slower, more manual, or more brittle?
- What routines absorb the change?

#### Dependency Cartographer

Primary concern:
- the actor's institutional, infrastructural, and relational dependencies

Best at surfacing:
- hidden dependencies
- single points of failure
- external chokepoints

Questions:
- What are we relying on without noticing?
- Which institutions or suppliers transmit this shock?
- Where are the non-obvious constraints?

#### Optionality Conservator

Primary concern:
- reversibility, flexibility, and preserved room to maneuver

Best at surfacing:
- path dependence
- lock-in risk
- sequencing choices

Questions:
- Which moves preserve future options?
- Which decisions become expensive to reverse?
- What should not be committed too early?

### 2. Permanent Challenge and Evidence Roles

These roles should be structurally present across impact work.

#### Contrarian

The Shell panel's insistence on a contrarian remains essential here.

Primary concern:
- consensus narratives
- false urgency
- second-order effects
- overreaction
- fragile assumptions

Questions:
- What if the headline story is directionally right but personally irrelevant?
- What are we overestimating?
- What "obvious" preparation is actually a trap?

#### Precedent Archivist

Primary concern:
- analogous situations and how actors previously adapted

This must not be limited to business comparisons.

Examples:

- how other households handled fuel shocks
- how buyers behaved in prior software hype cycles
- how schools or districts responded under budget squeeze
- how similarly exposed firms or families adapted to cost spikes

Questions:
- Who has already lived something structurally similar?
- What adaptations actually worked?
- What looked smart but failed in practice?

#### Signal Mason

Primary concern:
- the small set of facts, thresholds, and observations that materially change the call

This role interprets the "data bricks we need to understand."

Questions:
- What specific data matters here?
- What thresholds would change the recommendation?
- Which signals are decision-grade versus noise?
- What would confirm or falsify the live hypothesis?

#### Research Specialist

Primary concern:
- factual gap-filling, source evaluation, and contradiction resolution

#### Quality Analyst

Primary concern:
- prevent regression into generic advice
- preserve causal logic, specificity, and proper separation of impact from recommendation

### 3. Domain Overlays

These roles are attached when the query requires domain-specific interpretation.

#### Business / Commercial Overlay

For questions about product positioning, market entry, buying behavior, implementation, PMF, or GTM.

Potential borrowed role types:

- positioning specialist
- JTBD specialist
- PMF metrics specialist
- procurement/approval specialist
- implementation/change specialist

#### Household / Personal Overlay

For questions about family budgets, mobility, education, debt, provisioning, and daily life.

Potential role types:

- household provisioning realist
- care burden mapper
- education and transition observer
- mobility and commute pragmatist

#### Investor / Capital Overlay

For financing, portfolio, fundraising, and capital allocation questions.

#### Civic / Institutional Overlay

For schools, districts, public systems, regulation, and institutional transmission.

### 4. Dynamic Stakeholder Seats

These are assembled per query from the actor graph.

They are not permanent roles. They are case-specific seats representing the people who absorb burden, sign off, resist, pay, or live with the consequences.

Examples:

#### Personal / Household Example

Question:
"If an Iran-Gulf war creates global energy and inflation pressure, should I trade for an EV, stock up on coffee, or pay down debt faster?"

Dynamic stakeholder seats:

- the user as commuter and debtor
- the household as a shared budget system
- the significant other in the teacher seat
- the daughters in the college-dependent seat

#### Commercial Example

Question:
"We are launching an AI software product for middle-market manufacturing clients. How should we position it so they find it valuable enough to buy?"

Dynamic stakeholder seats:

- the user company
- middle-market manufacturing CFO
- plant manager
- IT/OT lead
- procurement lead
- frontline change skeptic

## Examples Of How The Architecture Changes Answers

### Example A: Personal Preparedness

Question:
"What does this mean to me and what should I prepare for?"

Likely architecture:

- external frame from Shell cast
- impact kernel active
- household/personal overlay active
- dynamic seats for household members
- contrarian, precedent archivist, signal mason active

Expected output:

- impact on budget
- impact on commuting
- impact on debt decisions
- impact on dependents and partner
- no-regret preparation
- signals to monitor

### Example B: Commercial Positioning

Question:
"How should we position our AI software for middle-market manufacturing clients?"

Likely architecture:

- external frame from Shell cast
- impact kernel active
- business/commercial overlay active
- dynamic buyer and operator seats
- contrarian, precedent archivist, signal mason active

Expected output:

- customer-side impact map
- changed buying criteria
- new objections and proof thresholds
- where the product genuinely reduces pain
- positioning implications

Positioning should not come directly from scenario logic. It should come from buyer-side impact.

## Orchestration Sequence

The recommended turn sequence for impact work:

1. **Freeze the external frame**
   - current situation, event, trend packet, scenario, or scenario set

2. **Identify the query contract**
   - meaning, preparedness, positioning, monitoring, decision support

3. **Build the actor graph**
   - who matters, who bears burden, who decides, who blocks

4. **Run the permanent impact kernel**
   - cash, friction, dependencies, optionality

5. **Run the domain overlay**
   - business, household, investor, civic, or mixed

6. **Run dynamic stakeholder seats**
   - lived-burden or buying-center reactions

7. **Run challenge/evidence passes**
   - contrarian
   - precedent archivist
   - signal mason
   - researcher if needed

8. **Moderator synthesizes the impact map**
   - preserve contradictions and burden trade-offs

9. **Generate the requested response mode**
   - preparedness memo, positioning memo, monitoring brief, decision memo, etc.

10. **Optional reflection pass**
   - relate back to worldview and baseline

## Candidate Output Family

The impact layer should likely support a family of outputs rather than one monolithic artifact.

Possible outputs:

- `impact_analysis.md`
- `preparedness_memo.md`
- `positioning_memo.md`
- `decision_memo.md`
- `monitoring_brief.md`

The underlying logic should be shared even if the final output mode changes.

## Open Design Questions

These should be resolved before schema and implementation:

1. Which kernel roles are mandatory in every run versus selectively invoked?
2. How many domain overlays should be formalized versus dynamically assembled?
3. How should personal/household overlays be named so they stay serious rather than cute?
4. Should impact exist as both:
   - a formal phase after external scenarios
   - a callable mode for direct user questions?
5. How should worldview influence impact in household and commercial cases?
6. What files should persist the actor graph and transmission map, if at all?
7. How should dynamic stakeholder seats be represented without pretending to know private interior states?
8. What quality checks ensure the panel does not skip from external frame directly to generic recommendation?

## Immediate Next Step

Before schema work, define each permanent impact persona with:

- role statement
- seat in the world
- proper name
- origin story / intellectual frame
- technical frameworks and terminology
- characteristic questions
- voice and communication style
- useful blind spot
- failure mode it catches
- when to invoke it
- analytical approach

And define for each persona:

- what real-world profile mix it is composed from
- what makes the composite plausible as a human being
- which dossier-level details are essential versus optional

This preserves the spirit of the Shell panel: unusual but grounded personas with strong lenses, not generic consultant functions.
