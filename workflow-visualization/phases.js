// ABOUTME: Phase definitions for Shell Scenario Panel workflow
// Complete worldview-first workflow with dedicated impact translation

const phases = [
  {
    number: 0,
    title: 'Worldview and Baseline',
    subtitle: 'Capture the user lens before scenario work',
    description: 'Elicit beliefs, internal baseline, and key context before moving into external analysis',
    rounds: [
      {
        number: 1,
        name: 'Worldview Elicitation',
        pattern: 'moderator-led',
        icon: '💬',
        description: 'Surface beliefs, cruxes, and reasoning',
        specialists: ['moderator']
      },
      {
        number: 2,
        name: 'Internal Baseline',
        pattern: 'moderator-led',
        icon: '🧭',
        description: 'Capture structured exposure, constraints, and risk posture',
        specialists: ['moderator']
      },
      {
        number: 3,
        name: 'Context Enrichment',
        pattern: 'research-informed',
        icon: '🔎',
        description: 'Resolve high-impact factual gaps with targeted research',
        specialists: ['moderator', 'researcher']
      }
    ],
    outputs: [
      'worldview_model.md - Beliefs, cruxes, and mental models',
      'phase_0_discovery/internal_baseline.md - Base case, exposure, risk posture',
      'phase_0_discovery/context_packet.md - Decision-grade factual context'
    ],
    invocations: '0-3',
    duration: '20-35 minutes',
    color: '#d4c4a8'
  },

  {
    number: 1,
    title: 'Understand the Focal Question',
    subtitle: 'Clarify decision context and scope',
    description: 'Define the strategic question, time horizon, and decision framework',
    rounds: [
      {
        number: 1,
        name: 'Moderator-Led Dialogue',
        pattern: 'moderator-led',
        icon: '💬',
        description: 'Targeted questions about decision context',
        specialists: ['moderator']
      }
    ],
    outputs: [
      'focal_question.md - Decision context, time horizon, scope'
    ],
    invocations: '0-2',
    duration: '10-15 minutes',
    color: '#e8dcc6'
  },

  {
    number: 2,
    title: 'Identify Predetermined Elements',
    subtitle: 'Map trends already in motion',
    description: 'Identify demographic, infrastructure, debt, and climate factors that are locked in',
    rounds: [
      {
        number: 1,
        name: 'Isolated Consultation',
        pattern: 'isolated',
        icon: '🔒',
        description: 'Each specialist identifies predetermined elements from their domain',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      }
    ],
    outputs: [
      'predetermined_elements.md - Domain-specific locked-in trends',
      'conversations/*_round1_full.md - Full specialist analyses (500+ words)',
      'conversations/*_round1_summary.md - Executive summaries (100 words)'
    ],
    invocations: '7',
    duration: '15-20 minutes',
    color: '#d4c4a8',
    diagram: 'isolated-specialists'
  },

  {
    number: 3,
    title: 'Identify Critical Uncertainties',
    subtitle: 'Progressive convergence pattern',
    description: 'Surface factors that could go multiple ways through multi-round collaboration',
    rounds: [
      {
        number: 1,
        name: 'Isolated Identification',
        pattern: 'isolated',
        icon: '🔒',
        description: 'Independent analysis of critical uncertainties',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      },
      {
        number: 2,
        name: 'Summary Convergence',
        pattern: 'summary-sharing',
        icon: '📝',
        description: 'Refine with exposure to other specialists summaries',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      }
    ],
    outputs: [
      'critical_uncertainties.md - 2-3 scenario-defining uncertainties',
      'conversations/*_round1_full.md + *_round1_summary.md',
      'conversations/*_round2_full.md + *_round2_summary.md'
    ],
    invocations: '14',
    duration: '25-35 minutes',
    color: '#e8dcc6',
    diagram: 'progressive-convergence'
  },

  {
    number: 4,
    title: 'Develop Scenario Narratives',
    subtitle: 'Cluster-based collaboration',
    description: 'Create plausible, divergent future scenarios through deep integration',
    rounds: [
      {
        number: 1,
        name: 'Independent Sketches',
        pattern: 'isolated',
        icon: '🔒',
        description: 'Explore scenario quadrants independently',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      },
      {
        number: 2,
        name: 'Cluster Refinement',
        pattern: 'cluster-based',
        icon: '🔗',
        description: 'Form clusters around scenario themes',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      },
      {
        number: 3,
        name: 'Full Integration',
        pattern: 'full-integration',
        icon: '🔗',
        description: 'Cross-cluster synthesis and challenge',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      }
    ],
    outputs: [
      'scenarios/scenario_1_[name].md - First future narrative',
      'scenarios/scenario_2_[name].md - Second future narrative',
      'scenarios/scenario_3_[name].md - Third future narrative',
      'scenarios/scenario_4_[name].md - Fourth future narrative',
      'conversations/*_round1/2/3_*.md - All specialist analyses'
    ],
    invocations: '21',
    duration: '40-60 minutes',
    color: '#d4c4a8',
    diagram: 'cluster-formation'
  },

  {
    number: 5,
    title: 'Identify Early Warning Signals',
    subtitle: 'Observable indicators for each scenario',
    description: 'Define specific, measurable signals that indicate which scenario is unfolding',
    rounds: [
      {
        number: 1,
        name: 'Signal Identification',
        pattern: 'isolated',
        icon: '🔒',
        description: 'Identify domain-specific indicators for all scenarios',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      }
    ],
    outputs: [
      'Updated scenario files with Early Warning Signals sections',
      'conversations/*_signals.md - Domain-specific indicators'
    ],
    invocations: '7',
    duration: '15-20 minutes',
    color: '#e8dcc6'
  },

  {
    number: '6a',
    title: 'Impact Analysis',
    subtitle: 'Translate scenarios into actor-relative consequence',
    description: 'Use the impact translation cast to map exposure, burden, optionality, precedent, and signals for the focal actor',
    rounds: [
      {
        number: 1,
        name: 'Impact Translation',
        pattern: 'actor-relative',
        icon: '🧩',
        description: 'Translate external futures into actor-level implications',
        specialists: ['ledger_keeper', 'friction_mechanic', 'dependency_cartographer', 'burden_cartographer', 'optionality_conservator', 'precedent_archivist', 'signal_mason', 'contrarian']
      }
    ],
    outputs: [
      'impact_analysis.md - Actor graph, transmission map, impact map, triggers',
      'conversations/*_impact.md - Impact specialist analyses'
    ],
    invocations: '8',
    duration: '20-30 minutes',
    color: '#d4c4a8'
  },

  {
    number: '6b',
    title: 'Test Strategies',
    subtitle: 'Response design under impact conditions',
    description: 'Evaluate strategy, preparedness, positioning, or response options using impact analysis as mandatory input',
    rounds: [
      {
        number: 1,
        name: 'Strategy Challenge',
        pattern: 'challenge',
        icon: '⚡',
        description: 'Test user strategies across scenarios and impact conditions',
        specialists: ['moderator', 'economist', 'contrarian', 'ledger_keeper', 'optionality_conservator']
      }
    ],
    outputs: [
      'strategy_analysis.md - Robust, adaptive, and conditional responses',
      'conversations/*_strategy.md - Strategy challenge analyses'
    ],
    invocations: '4-8',
    duration: '15-25 minutes',
    color: '#e8dcc6'
  },

  {
    number: 7,
    title: 'Worldview Integration',
    subtitle: 'Connect scenarios and impacts back to the user lens',
    description: 'Map beliefs, cruxes, and personalized signals across scenarios, impacts, and response options',
    rounds: [
      {
        number: 1,
        name: 'Worldview Reflection',
        pattern: 'worldview-reaction',
        icon: '🪞',
        description: 'Stress-test the original worldview against the completed scenario and impact work',
        specialists: ['contrarian', 'economist', 'anthropologist']
      }
    ],
    outputs: [
      'worldview_integration.md - Belief-by-belief integration',
      'conversations/*_worldview_reaction.md - Targeted worldview reactions'
    ],
    invocations: '3',
    duration: '10-20 minutes',
    color: '#d4c4a8'
  }
];

// Helper functions
function getPhase(number) {
  return phases.find(p => p.number === number);
}

function getTotalInvocations() {
  return phases.reduce((sum, phase) => {
    const count = parseInt(phase.invocations.split('-')[0], 10) || 0;
    return sum + count;
  }, 0);
}

function getPhasesNeedingDiagrams() {
  return phases.filter(p => p.diagram);
}
