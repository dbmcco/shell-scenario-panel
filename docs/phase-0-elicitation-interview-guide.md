ABOUTME: Phase 0 elicitation interview guide for internal base case capture.
ABOUTME: Provides question bank, metadata schema, and panel-specific add-ons.

# Phase 0 Elicitation Interview Guide

## Purpose

Capture the user's internal base case, assumptions, and risk posture before running external scenarios.
The goal is not to predict, but to map how the user currently sees the world so we can later show where external scenarios diverge.
Complete worldview elicitation first and capture `worldview_model.md` using the worldview-elicitor skill.

## Primary Outputs

- `worldview_model.md` (user worldview, cruxes, and mental models)
- `phase_0_discovery/internal_baseline.md` (user mental model, assumptions, risk posture)
- `company.md` (context, materials, and discovery history)

## Interview Flow (CLI Friendly)

1. **Framing and stakes**: clarify the decision and what is at risk.
2. **Base case narrative**: what the user thinks will most likely happen.
3. **Conditions and assumptions**: what must be true for the base case.
4. **Uncertainty map**: what is genuinely uncertain vs unknown.
5. **Risk calibration**: how much they would bet and what they would avoid.
6. **Disconfirmers**: what would change their mind.
7. **Participation and interaction metadata**: who is participating and how the process will run.

## Capture Schema (YAML Template)

```yaml
internal_baseline:
  decision_context:
    focal_decision: ""
    time_horizon: ""
    scope: ""
    stakes: ""
  base_case:
    most_likely_future: ""
    key_assumptions: []
    conditions_required: []
    confidence_level: low|medium|high
    disconfirmers: []
  uncertainty_map:
    uncertain_but_important: []
    unknown_but_improvable: []
  risk_profile:
    check_size: ""
    loss_tolerance: ""
    default_action_if_uncertain: ""
    comfort_with_ambiguity: low|medium|high
  decision_triggers:
    proceed_if: []
    pause_if: []
    kill_if: []
participation_characteristics:
  openness: public|registration|invite_only|private
  prep_required: none|light|moderate|extensive
  participant_count: ""
  reasons_for_participation: []
  anonymity: anonymous|pseudonymous|identified
  participant_types:
    education_level: ""
    professional_experience: ""
    discipline: ""
    age_band: ""
    geographic_origin: ""
interaction_characteristics:
  tasks_performed:
    - driver_identification
    - driver_exploration
    - driver_ranking_selection
    - driver_clustering_aggregation
    - scenario_logic_creation
    - scenario_logic_selection
    - scenario_logic_detailing
    - implications_development
    - implications_detailing
    - full_scenario_narrative_creation
  inputs_considered: []
  visualization_tools: []
  analytical_tools: []
  socialization_level: solo|small_group|workshop|public_forum
  feedback_modes: []
```

## Question Bank (Tagged)

### Framing and Stakes
- Q1: "What decision do you need to make, and by when?"  
  Captures: focal_decision, time_horizon.  
  Tags: decision_context, interaction: tasks_performed.
- Q2: "What is the downside if you get it wrong, and what is the upside if you get it right?"  
  Captures: stakes, loss_tolerance.  
  Tags: risk_profile.
- Q3: "What would be a clear win for you, even if the future stays uncertain?"  
  Captures: proceed_if, success criteria.  
  Tags: decision_triggers.

### Base Case Narrative
- Q4: "Describe the most likely future as you see it today."  
  Captures: most_likely_future.  
  Tags: base_case.
- Q5: "What has to be true for that future to happen?"  
  Captures: conditions_required, key_assumptions.  
  Tags: base_case.
- Q6: "Which two assumptions feel the most fragile?"  
  Captures: key_assumptions, uncertainty_map.  
  Tags: uncertainty_map.

### Uncertainty vs Risk
- Q7: "Which parts are unknowable, and which are just unknown but could be learned?"  
  Captures: uncertain_but_important, unknown_but_improvable.  
  Tags: uncertainty_map.
- Q8: "What are you implicitly assuming will stay stable?"  
  Captures: key_assumptions.  
  Tags: base_case.

### Risk Calibration
- Q9: "If this were a $10k bet, would you take it? What about if it were 10% of your annual income?"  
  Captures: check_size, loss_tolerance.  
  Tags: risk_profile.
- Q10: "When uncertainty spikes, do you tend to pause, hedge, or double down?"  
  Captures: default_action_if_uncertain.  
  Tags: risk_profile.
- Q11: "How much ambiguity can you tolerate before you need a decision rule?"  
  Captures: comfort_with_ambiguity.  
  Tags: risk_profile.

### Disconfirmers and Signals
- Q12: "What would change your mind about the base case within the next year?"  
  Captures: disconfirmers.  
  Tags: base_case, interaction: inputs_considered.
- Q13: "Which signals do you already track, and which would you trust to shift your view?"  
  Captures: inputs_considered, feedback_modes.  
  Tags: interaction_characteristics.

### Participation Characteristics (MIT Table 3.1)
- Q14: "Who is participating in this scenario process, and why?"  
  Captures: participant_count, reasons_for_participation.  
  Tags: participation_characteristics.
- Q15: "Is this private, invite-only, or open? Any anonymity expectations?"  
  Captures: openness, anonymity.  
  Tags: participation_characteristics.
- Q16: "What preparation has already been done or is required?"  
  Captures: prep_required.  
  Tags: participation_characteristics.
- Q17: "What backgrounds are represented (education, discipline, experience, geography)?"  
  Captures: participant_types.*  
  Tags: participation_characteristics.

### Interaction Characteristics (MIT Table 3.1)
- Q18: "Which scenario tasks do you want to perform here (drivers, ranking, clustering, implications, narratives)?"  
  Captures: tasks_performed.  
  Tags: interaction_characteristics.
- Q19: "What kinds of inputs should count as evidence (data, expert judgment, lived experience, docs)?"  
  Captures: inputs_considered.  
  Tags: interaction_characteristics.
- Q20: "Do you want visualizations, quantitative analysis, or a narrative-first approach?"  
  Captures: visualization_tools, analytical_tools.  
  Tags: interaction_characteristics.
- Q21: "How collaborative should this be: solo, small group, or workshop?"  
  Captures: socialization_level.  
  Tags: interaction_characteristics.
- Q22: "What kind of feedback do you want during the process (checkpoints, scoring, narrative review)?"  
  Captures: feedback_modes.  
  Tags: interaction_characteristics.

## Panel-Specific Add-Ons

### Shell Scenario Panel
- "Which drivers are most locked-in vs genuinely uncertain for your sector?"  
- "What is your current strategic posture (defensive, exploratory, offensive)?"

### VC Panel
- "What is your fund or personal risk posture (ownership targets, time to liquidity)?"  
- "What check sizes feel comfortable vs stressful for this deal?"  
- "What evidence would move you from interest to a term sheet?"

### Synthyra Panel
- "Which regulatory or public trust thresholds feel make-or-break?"  
- "Where do you expect your platform to compound vs stall?"

## Usage Notes

- Keep the elicitation separate from external scenario generation to reduce anchoring bias.
- Favor concrete thresholds and conditions over numeric probabilities.
- Use this guide to populate `internal_baseline.md` and then set it aside until reconciliation.
