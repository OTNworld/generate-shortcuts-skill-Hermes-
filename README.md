# Shortcuts Generator Skill for Hermes

A Hermes skill for AI-assisted generation of macOS/iOS Shortcuts. Create valid `.shortcut` plist files that can be signed and imported into Apple's Shortcuts app.

## Installation

### 1. Create the Hermes skills directory (if it doesn't exist)

```bash
mkdir -p ~/.hermes/skills
```

### 2. Clone or copy this repository

```bash
cd ~/.hermes/skills
git clone https://github.com/OTNworld/generate-shortcuts-skill-Hermes-.git shortcuts-generator
```

Or download and extract the files manually into `~/.hermes/skills/shortcuts-generator/`.

### 3. Verify the installation

Your directory structure should look like:

```
~/.hermes/skills/shortcuts-generator/
├── SKILL.md                  # Required - skill definition
├── README.md
├── references/
│   ├── ACTIONS.md
│   ├── APPINTENTS.md
│   ├── CONTROL_FLOW.md
│   ├── EXAMPLES.md
│   ├── FILTERS.md
│   ├── PARAMETER_TYPES.md
│   ├── PLIST_FORMAT.md
│   └── VARIABLES.md
├── scripts/
│   └── sign_shortcut.sh
└── templates/
    └── shortcut-skeleton.plist
```

### 4. Reload Hermes skills

Restart Hermes or reload skills so the new skill is detected.

## Usage

Once installed, ask Hermes to create a shortcut:

- "Create a shortcut that shows the current weather"
- "Build a shortcut that takes text input and shows it"
- "Make a shortcut that opens Safari and navigates to a URL"

Hermes will generate the plist XML, write it to a `.shortcut` file, and sign it so you can import it directly into the Shortcuts app.

## What's Included

| File | Description |
|------|-------------|
| `SKILL.md` | Skill definition with quick start guide |
| `references/ACTIONS.md` | All 427 WF*Action identifiers and parameters |
| `references/APPINTENTS.md` | All 728 AppIntent actions |
| `references/PARAMETER_TYPES.md` | Parameter value types and serialization formats |
| `references/VARIABLES.md` | Variable reference system |
| `references/CONTROL_FLOW.md` | Repeat, Conditional, Menu patterns |
| `references/FILTERS.md` | Content filters for Find/Filter actions |
| `references/EXAMPLES.md` | Complete working examples |
| `scripts/sign_shortcut.sh` | Shortcut signing helper |
| `templates/shortcut-skeleton.plist` | Minimal shortcut template |

## Requirements

- macOS with the `shortcuts` CLI tool (included with macOS)
- Hermes Agent

## License

MIT
