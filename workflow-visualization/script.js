// ABOUTME: Main script for Shell Scenario Panel workflow visualization
// Simplified version with placeholder graphics

// Configuration
const IMAGEN_API_KEY = typeof window !== 'undefined' && window.localStorage
  ? window.localStorage.getItem('IMAGEN_API_KEY') || ''
  : '';
const USE_IMAGEN = Boolean(IMAGEN_API_KEY);
const IMAGEN_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent';

if (!IMAGEN_API_KEY) {
  console.warn('Imagen API key missing; using placeholders for avatars and diagrams.');
}

// Image cache
const imageCache = {
  avatars: {},
  diagrams: {}
};

// ===== Image Generation Functions =====

async function generateImage(prompt) {
  try {
    const response = await fetch(IMAGEN_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': IMAGEN_API_KEY
      },
      body: JSON.stringify({
        contents: [{
          parts: [{ text: prompt }]
        }]
      })
    });

    if (!response.ok) {
      console.error(`API error: ${response.status}`);
      return null;
    }

    const data = await response.json();
    const imagePart = data.candidates?.[0]?.content?.parts?.find(p => p.inlineData);

    if (imagePart?.inlineData?.data) {
      return `data:${imagePart.inlineData.mimeType};base64,${imagePart.inlineData.data}`;
    }

    console.error('No image data in response');
    return null;
  } catch (error) {
    console.error('Error generating image:', error);
    return null;
  }
}

async function generatePersonaAvatar(persona) {
  if (imageCache.avatars[persona.id]) {
    return imageCache.avatars[persona.id];
  }

  if (!USE_IMAGEN) return null;

  console.log(`Generating avatar for ${persona.name}...`);
  const imageUrl = await generateImage(persona.avatarPrompt);

  if (imageUrl) {
    imageCache.avatars[persona.id] = imageUrl;
  }

  return imageUrl;
}

// ===== Helper Functions =====

function getPersonaInitials(name) {
  const parts = name.split(' ');
  if (parts.length >= 2) {
    return parts[0][0] + parts[1][0];
  }
  return name.substring(0, 2).toUpperCase();
}

function createPersonaCard(personaId, phaseNumber) {
  const persona = getPersona(personaId);
  if (!persona) return '';

  const card = document.createElement('div');
  card.className = 'persona-card';
  card.style.borderLeftColor = persona.color;

  const initials = getPersonaInitials(persona.name);

  card.innerHTML = `
    <div class="persona-avatar" style="background: linear-gradient(135deg, ${persona.color}, #e8dcc6);" data-persona="${personaId}">
      <span>${initials}</span>
    </div>
    <div class="persona-info">
      <div class="persona-name">${persona.name}</div>
      <div class="persona-title">${persona.title}</div>
      <div class="persona-expertise">${persona.expertise}</div>
    </div>
  `;

  // Load avatar asynchronously if enabled
  if (USE_IMAGEN) {
    loadPersonaAvatar(personaId, card);
  }

  return card;
}

async function loadPersonaAvatar(personaId, cardElement) {
  const persona = getPersona(personaId);
  const avatarDiv = cardElement.querySelector('.persona-avatar');
  const imageUrl = await generatePersonaAvatar(persona);

  if (imageUrl) {
    avatarDiv.innerHTML = `<img src="${imageUrl}" alt="${persona.name}" style="width: 100%; height: 100%; border-radius: 50%; object-fit: cover;">`;
  }
}

function getRoleForPhase(persona, phaseNumber) {
  const roleMap = {
    0: {
      moderator: 'Conducts interview and synthesizes research',
      default: 'Research company/market from domain'
    },
    1: {
      moderator: 'Facilitates focal question refinement',
      default: 'Provides domain context'
    },
    2: {
      default: 'Identify predetermined elements'
    },
    3: {
      default: 'Surface critical uncertainties'
    },
    4: {
      contrarian: 'Stress-test scenarios',
      default: 'Develop scenario narratives'
    },
    5: {
      default: 'Identify early warning signals'
    },
    6: {
      default: 'Test strategies across scenarios'
    }
  };

  const phaseRoles = roleMap[phaseNumber] || {};
  return phaseRoles[persona.id] || phaseRoles.default || 'Domain expertise';
}

function createRoundSection(round, phaseNumber) {
  const section = document.createElement('div');
  section.className = 'round';

  section.innerHTML = `
    <div class="round-header">
      <span class="round-icon">${round.icon}</span>
      <span class="round-title">Round ${round.number}: ${round.name}</span>
      <span class="round-pattern">${round.pattern}</span>
    </div>
    <div class="round-description">${round.description}</div>
    <div class="persona-grid"></div>
  `;

  // Add persona cards
  const personaGrid = section.querySelector('.persona-grid');
  round.specialists.forEach(specialistId => {
    const card = createPersonaCard(specialistId, phaseNumber);
    personaGrid.appendChild(card);
  });

  return section;
}

function createDiagram(diagramType) {
  const diagrams = {
    'isolated-specialists': `
      <svg viewBox="0 0 1200 400" style="max-width: 100%; height: auto;">
        <!-- Background -->
        <rect width="1200" height="400" fill="#ffffff"/>

        <!-- Title -->
        <text x="600" y="40" text-anchor="middle" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif" font-size="20" font-weight="600" fill="#b8956f">Phase 2 - Round 1: Isolated Analysis</text>

        <!-- 7 Specialist Nodes -->
        ${[0, 1, 2, 3, 4, 5, 6].map((i) => {
          const x = 150 + i * 150;
          return `
            <g>
              <circle cx="${x}" cy="200" r="45" fill="#e8dcc6" stroke="#b8956f" stroke-width="2.5"/>
              <text x="${x}" y="195" text-anchor="middle" font-family="sans-serif" font-size="14" font-weight="500" fill="#1a1a1a">Specialist</text>
              <text x="${x}" y="215" text-anchor="middle" font-family="sans-serif" font-size="18" font-weight="600" fill="#1a1a1a">${i + 1}</text>
              <text x="${x}" y="280" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#666666">🔒 Isolated</text>
            </g>
          `;
        }).join('')}

        <!-- Annotation -->
        <text x="600" y="340" text-anchor="middle" font-family="sans-serif" font-size="13" fill="#999999">Independent analysis · Zero information sharing · Each specialist works autonomously</text>
      </svg>
    `,
    'progressive-convergence': `
      <svg viewBox="0 0 1200 600" style="max-width: 100%; height: auto;">
        <!-- Background -->
        <rect width="1200" height="600" fill="#ffffff"/>

        <!-- Title -->
        <text x="600" y="40" text-anchor="middle" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif" font-size="20" font-weight="600" fill="#b8956f">Phase 3: Progressive Convergence Pattern</text>

        <!-- Round 1: Isolated (left column) -->
        <text x="250" y="90" text-anchor="middle" font-family="sans-serif" font-size="16" font-weight="600" fill="#1a1a1a">Round 1: 🔒 Isolated</text>
        ${[0, 1, 2, 3, 4, 5, 6].map((i) => {
          const x = 250;
          const y = 130 + i * 60;
          return `
            <g>
              <circle cx="${x}" cy="${y}" r="25" fill="#e8dcc6" stroke="#b8956f" stroke-width="2"/>
              <text x="${x}" y="${y + 5}" text-anchor="middle" font-family="sans-serif" font-size="12" font-weight="600" fill="#1a1a1a">${i + 1}</text>
            </g>
          `;
        }).join('')}
        <text x="250" y="540" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#999999">Independent analysis</text>

        <!-- Round 2: Summary Sharing (center column) -->
        <text x="600" y="90" text-anchor="middle" font-family="sans-serif" font-size="16" font-weight="600" fill="#1a1a1a">Round 2: 📝 Summary Sharing</text>
        ${[0, 1, 2, 3, 4, 5, 6].map((i) => {
          const x = 600;
          const y = 130 + i * 60;
          const fromY = 130 + i * 60;
          return `
            <g>
              <!-- Connection from Round 1 -->
              <line x1="275" y1="${fromY}" x2="575" y2="${y}" stroke="#b8956f" stroke-width="1" stroke-dasharray="4,4" opacity="0.5"/>
              <circle cx="${x}" cy="${y}" r="25" fill="#d4c4a8" stroke="#b8956f" stroke-width="2"/>
              <text x="${x}" y="${y + 5}" text-anchor="middle" font-family="sans-serif" font-size="12" font-weight="600" fill="#1a1a1a">${i + 1}</text>
            </g>
          `;
        }).join('')}
        <!-- Summary document icon -->
        <rect x="580" y="510" width="40" height="50" fill="none" stroke="#d4a574" stroke-width="2" rx="3"/>
        <line x1="590" y1="525" x2="610" y2="525" stroke="#d4a574" stroke-width="1.5"/>
        <line x1="590" y1="535" x2="610" y2="535" stroke="#d4a574" stroke-width="1.5"/>
        <line x1="590" y1="545" x2="610" y2="545" stroke="#d4a574" stroke-width="1.5"/>
        <text x="600" y="575" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#999999">~700 words shared</text>

        <!-- Round 3: Full Integration (right) -->
        <text x="950" y="90" text-anchor="middle" font-family="sans-serif" font-size="16" font-weight="600" fill="#1a1a1a">Round 3: 🔗 Full Integration</text>
        <circle cx="950" cy="300" r="80" fill="#f5f1e8" stroke="#b8956f" stroke-width="3"/>
        <text x="950" y="290" text-anchor="middle" font-family="sans-serif" font-size="14" font-weight="600" fill="#1a1a1a">All 7</text>
        <text x="950" y="310" text-anchor="middle" font-family="sans-serif" font-size="14" fill="#666666">Specialists</text>

        <!-- Connection lines from Round 2 to Round 3 -->
        ${[0, 1, 2, 3, 4, 5, 6].map((i) => {
          const fromY = 130 + i * 60;
          const angle = (i / 7) * Math.PI * 2 - Math.PI / 2;
          const toX = 950 + Math.cos(angle) * 75;
          const toY = 300 + Math.sin(angle) * 75;
          return `<line x1="625" y1="${fromY}" x2="${toX}" y2="${toY}" stroke="#b8956f" stroke-width="1.5" opacity="0.4"/>`;
        }).join('')}

        <text x="950" y="420" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#999999">Complete synthesis</text>
        <text x="950" y="435" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#999999">~3500+ words</text>

        <!-- Flow arrows -->
        <defs>
          <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
            <polygon points="0 0, 10 3, 0 6" fill="#d4a574"/>
          </marker>
        </defs>
        <path d="M 410 300 L 460 300" stroke="#d4a574" stroke-width="2" fill="none" marker-end="url(#arrowhead)"/>
        <path d="M 760 300 L 810 300" stroke="#d4a574" stroke-width="2" fill="none" marker-end="url(#arrowhead)"/>
      </svg>
    `,
    'cluster-formation': `
      <svg viewBox="0 0 1200 500" style="max-width: 100%; height: auto;">
        <!-- Background -->
        <rect width="1200" height="500" fill="#ffffff"/>

        <!-- Title -->
        <text x="600" y="40" text-anchor="middle" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif" font-size="20" font-weight="600" fill="#b8956f">Phase 4: Cluster-Based Scenario Development</text>

        <!-- Cluster A (left) -->
        <rect x="60" y="100" width="250" height="320" fill="#f5f1e8" stroke="#b8956f" stroke-width="2" rx="8"/>
        <text x="185" y="130" text-anchor="middle" font-family="sans-serif" font-size="16" font-weight="600" fill="#1a1a1a">Scenario A Cluster</text>
        ${[0, 1, 2].map((i) => {
          const x = 105 + i * 70;
          const y = 200;
          return `
            <g>
              <circle cx="${x}" cy="${y}" r="28" fill="#e8dcc6" stroke="#b8956f" stroke-width="2"/>
              <text x="${x}" y="${y + 5}" text-anchor="middle" font-family="sans-serif" font-size="13" font-weight="600" fill="#1a1a1a">S${i + 1}</text>
              <line x1="${x}" y1="${y + 32}" x2="${x}" y2="${y + 55}" stroke="#b8956f" stroke-width="1.5"/>
            </g>
          `;
        }).join('')}
        <rect x="85" y="275" width="200" height="100" fill="#ffffff" stroke="#d4a574" stroke-width="1.5" rx="4"/>
        <text x="185" y="305" text-anchor="middle" font-family="sans-serif" font-size="12" font-weight="600" fill="#1a1a1a">Scenario A</text>
        <text x="185" y="325" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#666666">Optimistic future</text>
        <text x="185" y="345" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#666666">High tech, cooperation</text>

        <!-- Cluster B (center) -->
        <rect x="380" y="100" width="250" height="320" fill="#f5f1e8" stroke="#b8956f" stroke-width="2" rx="8"/>
        <text x="505" y="130" text-anchor="middle" font-family="sans-serif" font-size="16" font-weight="600" fill="#1a1a1a">Scenario B Cluster</text>
        ${[0, 1].map((i) => {
          const x = 440 + i * 70;
          const y = 200;
          return `
            <g>
              <circle cx="${x}" cy="${y}" r="28" fill="#e8dcc6" stroke="#b8956f" stroke-width="2"/>
              <text x="${x}" y="${y + 5}" text-anchor="middle" font-family="sans-serif" font-size="13" font-weight="600" fill="#1a1a1a">S${i + 4}</text>
              <line x1="${x}" y1="${y + 32}" x2="${x}" y2="${y + 55}" stroke="#b8956f" stroke-width="1.5"/>
            </g>
          `;
        }).join('')}
        <rect x="405" y="275" width="200" height="100" fill="#ffffff" stroke="#d4a574" stroke-width="1.5" rx="4"/>
        <text x="505" y="305" text-anchor="middle" font-family="sans-serif" font-size="12" font-weight="600" fill="#1a1a1a">Scenario B</text>
        <text x="505" y="325" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#666666">Fragmented world</text>
        <text x="505" y="345" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#666666">Regional blocs</text>

        <!-- Cluster C (right) -->
        <rect x="700" y="100" width="250" height="320" fill="#f5f1e8" stroke="#b8956f" stroke-width="2" rx="8"/>
        <text x="825" y="130" text-anchor="middle" font-family="sans-serif" font-size="16" font-weight="600" fill="#1a1a1a">Scenario C Cluster</text>
        ${[0, 1].map((i) => {
          const x = 760 + i * 70;
          const y = 200;
          return `
            <g>
              <circle cx="${x}" cy="${y}" r="28" fill="#e8dcc6" stroke="#b8956f" stroke-width="2"/>
              <text x="${x}" y="${y + 5}" text-anchor="middle" font-family="sans-serif" font-size="13" font-weight="600" fill="#1a1a1a">S${i + 6}</text>
              <line x1="${x}" y1="${y + 32}" x2="${x}" y2="${y + 55}" stroke="#b8956f" stroke-width="1.5"/>
            </g>
          `;
        }).join('')}
        <rect x="725" y="275" width="200" height="100" fill="#ffffff" stroke="#d4a574" stroke-width="1.5" rx="4"/>
        <text x="825" y="305" text-anchor="middle" font-family="sans-serif" font-size="12" font-weight="600" fill="#1a1a1a">Scenario C</text>
        <text x="825" y="325" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#666666">Resource scarcity</text>
        <text x="825" y="345" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#666666">Climate stress</text>

        <!-- Researcher (bridging all clusters) -->
        <circle cx="1080" cy="260" r="30" fill="#d4a574" stroke="#b8956f" stroke-width="2.5"/>
        <text x="1080" y="256" text-anchor="middle" font-family="sans-serif" font-size="11" font-weight="600" fill="#ffffff">Research</text>
        <text x="1080" y="269" text-anchor="middle" font-family="sans-serif" font-size="9" fill="#ffffff">Specialist</text>

        <!-- Bridge lines from researcher to clusters -->
        <line x1="1050" y1="260" x2="310" y2="210" stroke="#d4a574" stroke-width="1.5" stroke-dasharray="5,5" opacity="0.6"/>
        <line x1="1050" y1="260" x2="630" y2="210" stroke="#d4a574" stroke-width="1.5" stroke-dasharray="5,5" opacity="0.6"/>
        <line x1="1050" y1="260" x2="950" y2="210" stroke="#d4a574" stroke-width="1.5" stroke-dasharray="5,5" opacity="0.6"/>

        <text x="1080" y="315" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#999999">Bridges all</text>
        <text x="1080" y="330" text-anchor="middle" font-family="sans-serif" font-size="10" fill="#999999">scenarios</text>
      </svg>
    `
  };

  return diagrams[diagramType] || '<p>Diagram placeholder</p>';
}

function createPhaseSection(phase) {
  const section = document.createElement('section');
  section.className = 'phase-section';
  section.id = `phase-${phase.number}`;

  const badgeClass = phase.optional ? 'phase-badge optional' : 'phase-badge';
  const optionalText = phase.optional ? ' (Optional)' : '';

  section.innerHTML = `
    <div class="phase-header">
      <div class="${badgeClass}">Phase ${phase.number}${optionalText}</div>
      <h2>${phase.title}</h2>
      <p class="subtitle">${phase.subtitle}</p>
      <div class="phase-meta">
        <span>📊 ${phase.invocations} invocations</span>
        <span>⏱️ ${phase.duration}</span>
        <span>🔄 ${phase.rounds.length} round(s)</span>
      </div>
    </div>
    <div class="rounds-container"></div>
    <div class="outputs">
      <h4>📄 Key Outputs</h4>
      <ul>
        ${phase.outputs.map(output => `<li>${output}</li>`).join('')}
      </ul>
    </div>
  `;

  // Add rounds
  const roundsContainer = section.querySelector('.rounds-container');
  phase.rounds.forEach(round => {
    const roundSection = createRoundSection(round, phase.number);
    roundsContainer.appendChild(roundSection);
  });

  // Add diagram if specified
  if (phase.diagram) {
    const diagramContainer = document.createElement('div');
    diagramContainer.className = 'diagram-container';
    diagramContainer.innerHTML = createDiagram(phase.diagram);
    roundsContainer.insertBefore(diagramContainer, roundsContainer.firstChild);
  }

  return section;
}

// ===== Navigation =====

function initializeNavigation() {
  const navLinks = document.querySelectorAll('.phase-nav a');

  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      navLinks.forEach(l => l.classList.remove('active'));
      link.classList.add('active');
    });
  });

  // Update active nav on scroll
  window.addEventListener('scroll', () => {
    const sections = document.querySelectorAll('.phase-section');
    let current = '';

    sections.forEach(section => {
      const sectionTop = section.offsetTop;
      if (window.scrollY >= (sectionTop - 200)) {
        current = section.getAttribute('id');
      }
    });

    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${current}`) {
        link.classList.add('active');
      }
    });
  });
}

// ===== Overview Diagram =====

function createOverviewDiagram() {
  return `
    <svg viewBox="0 0 1200 300" style="max-width: 100%; height: auto;">
      <!-- Background -->
      <rect width="1200" height="300" fill="#ffffff"/>

      <!-- Title -->
      <text x="600" y="30" text-anchor="middle" font-family="-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif" font-size="18" font-weight="600" fill="#1a1a1a">7-Phase Workflow Overview</text>

      <!-- Phase boxes and connections -->
      ${phases.map((phase, i) => {
        const x = 80 + i * 160;
        const y = 100;
        const isOptional = phase.optional;
        const boxColor = isOptional ? '#d4a574' : '#b8956f';
        const textColor = '#ffffff';

        return `
          <g>
            <!-- Phase box -->
            <rect x="${x - 50}" y="${y}" width="100" height="120" fill="${boxColor}" stroke="#1a1a1a" stroke-width="2" rx="6"/>

            <!-- Phase number -->
            <text x="${x}" y="${y + 30}" text-anchor="middle" font-family="sans-serif" font-size="24" font-weight="700" fill="${textColor}">P${phase.number}</text>

            <!-- Phase name (wrapped) -->
            <text x="${x}" y="${y + 55}" text-anchor="middle" font-family="sans-serif" font-size="11" font-weight="500" fill="${textColor}">
              ${phase.title.split(' ').slice(0, 2).join(' ')}
            </text>
            ${phase.title.split(' ').length > 2 ? `
              <text x="${x}" y="${y + 70}" text-anchor="middle" font-family="sans-serif" font-size="11" font-weight="500" fill="${textColor}">
                ${phase.title.split(' ').slice(2).join(' ')}
              </text>
            ` : ''}

            <!-- Invocations -->
            <text x="${x}" y="${y + 95}" text-anchor="middle" font-family="sans-serif" font-size="10" fill="${textColor}" opacity="0.9">
              ${phase.invocations} inv
            </text>

            <!-- Rounds -->
            <text x="${x}" y="${y + 110}" text-anchor="middle" font-family="sans-serif" font-size="9" fill="${textColor}" opacity="0.8">
              ${phase.rounds.length} round${phase.rounds.length > 1 ? 's' : ''}
            </text>

            ${isOptional ? `
              <text x="${x}" y="${y - 10}" text-anchor="middle" font-family="sans-serif" font-size="9" font-weight="600" fill="#d4a574">
                Optional
              </text>
            ` : ''}

            <!-- Connection arrow to next phase -->
            ${i < phases.length - 1 ? `
              <defs>
                <marker id="arrow-${i}" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto">
                  <polygon points="0 0, 8 4, 0 8" fill="#666666"/>
                </marker>
              </defs>
              <line x1="${x + 50}" y1="${y + 60}" x2="${x + 110}" y2="${y + 60}" stroke="#666666" stroke-width="2" marker-end="url(#arrow-${i})"/>
            ` : ''}
          </g>
        `;
      }).join('')}

      <!-- Legend -->
      <g transform="translate(100, 250)">
        <text x="0" y="0" font-family="sans-serif" font-size="11" fill="#999999">
          Total: ~68-72 invocations across all phases
        </text>
      </g>
    </svg>
  `;
}

// ===== Initialization =====

function initializeTimeline() {
  // Create overview diagram
  const overviewContainer = document.getElementById('overview-diagram');
  if (overviewContainer) {
    overviewContainer.innerHTML = createOverviewDiagram();
  }

  const timelineContainer = document.getElementById('timeline-phases');

  // Create and append all phase sections
  phases.forEach(phase => {
    const phaseSection = createPhaseSection(phase);
    timelineContainer.appendChild(phaseSection);
  });

  // Update total invocations
  const total = phases.reduce((sum, p) => sum + parseInt(p.invocations.split('-')[0] || 0), 0);
  document.getElementById('total-invocations').textContent = `~${total}`;

  // Initialize navigation
  initializeNavigation();

  console.log('Timeline initialized successfully');
}

// Run on page load
document.addEventListener('DOMContentLoaded', initializeTimeline);
