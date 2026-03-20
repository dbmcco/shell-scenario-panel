# Shell Scenario Panel Workflow Visualization

Educational visualization of the Shell Scenario Panel multi-agent workflow, built with LightForge Works branding.

## Overview

This interactive HTML visualization shows the Shell Scenario Panel workflow, including:
- World-modeling and impact personas with AI-generated avatars
- Progressive convergence patterns across phases
- Round-by-round collaboration structures
- Information flow diagrams
- Key outputs and deliverables
- A model-mediated workflow snapshot (`workflow-model-mediated.html`)

## Features

### 🎨 LightForge Works Branding
- Custom color palette (#1a1a1a, #b8956f, #d4c4a8, #e8dcc6)
- Professional typography and spacing
- Clean, minimal aesthetic matching LFW website

### 🤖 AI-Generated Content
- **Persona Avatars**: Generated via Google Imagen 3 (nano banana)
- **Workflow Diagrams**: AI-generated collaboration patterns
- **Caching**: Generated images cached to avoid repeated API calls

### 📱 Responsive Design
- Fixed sidebar navigation
- Smooth scrolling timeline
- Mobile-friendly layout
- Hover effects and interactions

### 📊 Educational Content
- Worldview-first workflow with detailed phase breakdowns
- Round structure visualization (isolated → summary → full integration)
- Information flow indicators (🔒 🔗 📝)
- Specialist roles and expertise
- Phase outputs and deliverables

## File Structure

```
workflow-visualization/
├── index.html          # Main HTML structure
├── workflow-model-mediated.html # Model-mediated guardrails snapshot
├── styles.css          # LFW-branded styling
├── script.js           # Imagen API integration & DOM manipulation
├── personas.js         # World-modeling and impact persona definitions
├── phases.js           # Workflow phase data
├── generated/          # Cached AI-generated images
│   ├── avatars/       # Persona headshots (auto-generated)
│   └── diagrams/      # Workflow diagrams (auto-generated)
└── README.md          # This file
```

## Usage

### Quick Start

1. **Open the visualization:**
   ```bash
   cd /Users/braydon/projects/experiments/ai-simulations/shell-scenario-panel/workflow-visualization
   open index.html
   ```

2. **Or serve with a local server:**
   ```bash
   python3 -m http.server 8000
   # Then visit http://localhost:8000
   ```

### Navigation

- **Sidebar**: Click any phase to jump directly
- **Scroll**: Smooth scroll through the timeline
- **Hover**: Persona cards show hover effects
- **Auto-highlight**: Active phase highlighted in sidebar as you scroll

## AI Image Generation

### Imagen 3 API Integration

The visualization uses Google's Imagen 3 (nano banana) model to generate:

1. **Persona Avatars**:
   - Professional headshots based on persona descriptions
   - Unique styling for each specialist
   - Cached after first generation

2. **Workflow Diagrams** (3 total):
   - Progressive convergence visualization (Phase 3)
   - Cluster formation diagram (Phase 4)
   - Isolated specialists pattern (Phase 2)

### API Configuration

API key is loaded from browser localStorage (not committed to the repo):
```javascript
localStorage.setItem('IMAGEN_API_KEY', 'YOUR_KEY_HERE');
```

`script.js` reads it at runtime:
```javascript
const IMAGEN_API_KEY = localStorage.getItem('IMAGEN_API_KEY') || '';
```

**Note**: Images are generated on first page load, then cached. Subsequent loads use cached versions.

## Customization

### Adding New Personas

Edit `personas.js`:
```javascript
newPersona: {
  id: 'newpersona',
  name: 'Dr. New Person',
  title: 'Specialist Title',
  expertise: 'Key skills',
  description: 'What they do',
  color: '#hexcolor',
  avatarPrompt: 'Professional headshot of...',
  phases: [0, 2, 3, 4, 5, 6]
}
```

### Modifying Phases

Edit `phases.js` to update:
- Phase descriptions
- Round structures
- Outputs
- Specialist assignments

### Styling Changes

Edit `styles.css` CSS variables:
```css
:root {
  --primary-dark: #1a1a1a;
  --accent-bronze: #b8956f;
  /* etc. */
}
```

## Technical Details

### Dependencies
- **Zero build tools** - Vanilla HTML/CSS/JS
- **Google Imagen 3 API** - Image generation
- **Fetch API** - HTTP requests
- **Modern browsers** - ES6+ JavaScript

### Browser Compatibility
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

### Performance
- Initial load: ~10-15 seconds (image generation)
- Subsequent loads: <1 second (cached images)
- Smooth scrolling with CSS scroll-behavior
- Responsive down to 320px width

## Workflow Summary

### Phase 0: Worldview and Baseline
- 0-3 invocations
- Capture worldview, internal baseline, and decision-grade context
- Generates `worldview_model.md`, `internal_baseline.md`, and `context_packet.md`

### Phase 1: Focal Question
- 0-2 invocations
- Moderator-led refinement
- Defines strategic context

### Phase 2: Predetermined Elements
- 7 invocations
- 1 round, isolated consultation
- Maps locked-in trends

### Phase 3: Critical Uncertainties
- 14 invocations
- 2 rounds with progressive convergence
- Identifies scenario axes

### Phase 4: Scenario Development
- 21 invocations
- 3 rounds with cluster-based collaboration
- Creates 4 divergent future narratives

### Phase 5: Early Warning Signals
- 7 invocations
- 1 round, isolated
- Defines observable indicators

### Phase 6a: Impact Analysis
- 8 invocations
- 1 round, actor-relative translation
- Produces `impact_analysis.md`

### Phase 6b: Strategy Testing
- 4-8 invocations
- 1 round, challenge pattern
- Uses `impact_analysis.md` as mandatory input

### Phase 7: Worldview Integration
- 3 invocations
- 1 round, worldview reaction
- Connects scenarios, impacts, and responses back to the user lens

**Minimum footprint: ~64+ invocations depending on response mode**

## Credits

- **Methodology**: Shell Scenario Planning (Pierre Wack, Ted Newland)
- **Architecture**: DraftForge multi-agent patterns
- **Branding**: LightForge Works
- **AI Generation**: Google Imagen 3 (nano banana)
- **Implementation**: Claude Code + Braydon

## License

Part of the Shell Scenario Panel project.
See parent directory for license information.
