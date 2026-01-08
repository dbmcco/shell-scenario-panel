# Skills for Shell Scenario Panel

This directory contains skills required for the Shell Scenario Panel to function properly.

## worldview-elicitor

The worldview-elicitor skill is used in Phase 0 to understand how the user thinks about the topic before exploring external scenarios.

### Installation

**Option 1: Symlink (Recommended)**

Create a symlink from your Claude Code skills directory to this skill:

```bash
# Create the skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Create a symlink
ln -s "$(pwd)/skills/worldview-elicitor" ~/.claude/skills/worldview-elicitor
```

**Option 2: Copy**

Copy the skill to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills
cp -r skills/worldview-elicitor ~/.claude/skills/
```

### Verification

After installation, verify the skill is available:

```bash
ls ~/.claude/skills/worldview-elicitor/
# Should show: skill.md
```

### Usage

The skill is invoked automatically by Dr. Wells during Phase 0 using:

```
Skill("worldview-elicitor")
```

You don't need to invoke it manually.

## Adding New Skills

If you develop additional skills for the Shell Scenario Panel, add them to this directory following the same structure:

```
skills/
├── README.md
├── worldview-elicitor/
│   └── skill.md
└── your-new-skill/
    └── skill.md
```

Each skill should have:
- A `skill.md` file with frontmatter containing `name` and `description`
- Clear instructions for how to use the skill
- Any supporting files in the same directory
