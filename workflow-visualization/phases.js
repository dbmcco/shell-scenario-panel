// ABOUTME: Phase definitions for Shell Scenario Panel workflow
// Complete 7-phase process with rounds, outputs, and collaboration patterns

const phases = [
  {
    number: 0,
    title: 'Company Discovery',
    subtitle: 'Intelligent interview loop with specialist research',
    description: 'Build comprehensive understanding through user interviews and multi-perspective research',
    optional: true,
    rounds: [
      {
        number: 1,
        name: 'Initial Interview',
        pattern: 'moderator-led',
        icon: '💬',
        description: '2-3 basic questions to establish foundation',
        specialists: ['moderator']
      },
      {
        number: 2,
        name: 'Specialist Research',
        pattern: 'isolated',
        icon: '🔒',
        description: 'All 6 domain specialists research independently',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian']
      },
      {
        number: 3,
        name: 'Follow-up Interview',
        pattern: 'research-informed',
        icon: '📝',
        description: 'Questions informed by research findings',
        specialists: ['moderator']
      }
    ],
    outputs: [
      'company.md - Comprehensive company profile',
      'phase_0_discovery/research/ - 6 specialist discovery transcripts',
      'scenario_suggestions.md - AI-generated focal question recommendations'
    ],
    invocations: '12-14',
    duration: '30-45 minutes',
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
        description: 'Refine with exposure to other specialists\' summaries',
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
    description: 'Create 4 plausible, divergent future scenarios through deep integration',
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
    number: 6,
    title: 'Test Strategies',
    subtitle: 'Identify robust and adaptive approaches',
    description: 'Evaluate strategy performance across all scenarios',
    rounds: [
      {
        number: 1,
        name: 'Strategy Testing',
        pattern: 'challenge',
        icon: '⚡',
        description: 'Test user strategies across all scenarios',
        specialists: ['ecologist', 'geopolitician', 'anthropologist', 'futurist', 'economist', 'contrarian', 'researcher']
      }
    ],
    outputs: [
      'strategy_analysis.md - Robust and adaptive strategy recommendations',
      'conversations/*_strategy.md - Domain-specific strategy analyses'
    ],
    invocations: '7',
    duration: '15-20 minutes',
    color: '#d4c4a8'
  }
];

// Helper functions
function getPhase(number) {
  return phases.find(p => p.number === number);
}

function getTotalInvocations() {
  return phases.reduce((sum, phase) => {
    const count = parseInt(phase.invocations.split('-')[0]) || 0;
    return sum + count;
  }, 0);
}

function getPhasesNeedingDiagrams() {
  return phases.filter(p => p.diagram);
}
