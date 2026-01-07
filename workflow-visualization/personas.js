// ABOUTME: Persona definitions for Shell Scenario Panel specialists
// All 8 personas with their expertise, roles, and visual identities

const personas = {
  moderator: {
    id: 'moderator',
    name: 'Dr. Michelle Wells',
    title: 'Scenario Planning Facilitator',
    expertise: 'Orchestration, synthesis, facilitation',
    description: 'Trained by Shell pioneers, orchestrates diverse expert input and synthesizes complex perspectives',
    color: '#b8956f', // Bronze - appears in all phases
    avatarPrompt: 'Professional corporate headshot: Confident female business facilitator, age 50-55, warm approachable smile, wearing dark blazer over white blouse, short professional hairstyle, neutral gray studio background with soft lighting, shoulders visible in frame, eye-level camera angle, high-quality executive portrait photography style like LinkedIn professional photos',
    phases: [0, 1, 2, 3, 4, 5, 6]
  },

  ecologist: {
    id: 'ecologist',
    name: 'Dr. Elena Vasquez',
    title: 'Systems Ecologist',
    expertise: 'Feedback loops, interdependencies, resilience',
    description: 'Analyzes systems dynamics, environmental constraints, and resource dependencies',
    color: '#a8c4a8', // Green-tinted beige
    avatarPrompt: 'Professional corporate headshot: Thoughtful female environmental scientist, age 40-45, wearing modern glasses, intelligent focused expression, olive green blazer, hair pulled back professionally, neutral gray studio background, shoulders visible, eye-level angle, expert consultant portrait style with natural lighting',
    phases: [0, 2, 3, 4, 5, 6]
  },

  geopolitician: {
    id: 'geopolitician',
    name: 'Dr. Marcus Chen',
    title: 'Geopolitical Analyst',
    expertise: 'Power dynamics, resources, state interests',
    description: 'Examines geopolitical forces, resource competition, and strategic alignments',
    color: '#a8b8c8', // Blue-tinted beige
    avatarPrompt: 'Professional corporate headshot: Authoritative East Asian male geopolitical strategist, age 50-55, confident serious expression, charcoal gray suit with conservative tie, short neat hair, neutral gray studio background, shoulders and upper chest visible, eye-level camera, senior executive portrait photography style',
    phases: [0, 2, 3, 4, 5, 6]
  },

  anthropologist: {
    id: 'anthropologist',
    name: 'Dr. Aisha Okonkwo',
    title: 'Cultural Anthropologist',
    expertise: 'Values, meaning-making, lived experience',
    description: 'Studies cultural shifts, value changes, and human behavioral patterns',
    color: '#c8b8d4', // Purple-tinted beige
    avatarPrompt: 'Professional corporate headshot: Insightful African female cultural anthropologist, age 40-45, warm empathetic smile, wearing burgundy blazer, natural hair styled professionally, neutral gray studio background with soft diffused lighting, shoulders visible, eye-level perspective, academic-professional portrait style',
    phases: [0, 2, 3, 4, 5, 6]
  },

  futurist: {
    id: 'futurist',
    name: 'Dr. Kenji Tanaka',
    title: 'Technology Futurist',
    expertise: 'Capability thresholds, platform shifts, S-curves',
    description: 'Analyzes technology trajectories, inflection points, and capability evolution',
    color: '#d4b890', // Orange-tinted beige
    avatarPrompt: 'Professional corporate headshot: Forward-thinking Japanese male technology futurist, age 40-45, wearing modern thin-frame glasses, slight thoughtful smile, navy blazer over open-collar shirt, contemporary hairstyle, neutral gray studio background, shoulders visible, eye-level angle, tech consultant portrait style with crisp lighting',
    phases: [0, 2, 3, 4, 5, 6]
  },

  economist: {
    id: 'economist',
    name: 'Dr. Sarah Blackwood',
    title: 'Financial Economist',
    expertise: 'Debt dynamics, financial structures, regime shifts',
    description: 'Examines economic forces, financial constraints, and monetary dynamics',
    color: '#d4a574', // Gold accent
    avatarPrompt: 'Professional corporate headshot: Sharp analytical female economist, age 40-45, confident direct gaze, wearing tailored charcoal blazer with subtle jewelry, blonde hair in sleek professional style, neutral gray studio background, shoulders and upper chest visible, eye-level camera, financial services executive portrait photography',
    phases: [0, 2, 3, 4, 5, 6]
  },

  contrarian: {
    id: 'contrarian',
    name: 'Dr. Jamie O\'Sullivan',
    title: 'Contrarian Provocateur',
    expertise: 'Hidden risks, fragilities, challenging assumptions',
    description: 'Challenges comfortable thinking, surfaces blind spots, and stress-tests plausibility',
    color: '#d4a8a8', // Red-tinted beige
    avatarPrompt: 'Professional corporate headshot: Skeptical Irish contrarian analyst, age 40-45, slight raised eyebrow with questioning expression, red hair, wearing casual blazer over patterned shirt, neutral gray studio background with dramatic side lighting, shoulders visible, eye-level angle, provocative intellectual consultant portrait style',
    phases: [0, 2, 3, 4, 5, 6]
  },

  researcher: {
    id: 'researcher',
    name: 'Dr. Anya Petrov',
    title: 'Research Specialist',
    expertise: 'Multi-source synthesis, fact-checking, contradiction resolution',
    description: 'Conducts comprehensive research when knowledge gaps emerge across specialists',
    color: '#b8b8b8', // Gray-tinted beige
    avatarPrompt: 'Professional corporate headshot: Meticulous Eastern European female researcher, age 30-35, intensely focused expression, dark-framed glasses, wearing white blouse under charcoal vest, hair in neat bun, neutral gray studio background with bright even lighting, shoulders visible, eye-level perspective, academic research consultant portrait photography',
    phases: [0, 2, 3, 4, 5, 6]
  },

  quality: {
    id: 'quality',
    name: 'Dr. Mei Chen',
    title: 'Quality Analyst',
    expertise: 'Intellectual integrity, quality gates, synthesis evaluation',
    description: 'Audits work quality and prevents regression to generic analysis',
    color: '#a8d4c8', // Teal-tinted beige
    avatarPrompt: 'Professional corporate headshot: Exacting East Asian female quality analyst, age 40-45, serious precise expression, wearing navy blazer with crisp white shirt, hair in professional bob cut, neutral gray studio background with sharp focused lighting, shoulders visible, eye-level camera angle, quality assurance executive portrait photography style',
    phases: [2, 3, 4] // Quality gates at key phase transitions
  }
};

// Helper function to get personas for a specific phase
function getPersonasForPhase(phaseNumber) {
  return Object.values(personas).filter(p => p.phases.includes(phaseNumber));
}

// Helper function to get persona by ID
function getPersona(id) {
  return personas[id];
}
