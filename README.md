# Shortcuts Generator Skill for Hermes

A Hermes skill for AI-assisted generation of macOS/iOS Shortcuts. Create valid `.shortcut` plist files that can be signed and imported into Apple's Shortcuts app.

## Language policy

| Surface | Language | Why |
|---------|----------|-----|
| `SKILL.md` (Hermes prompts / workflow) | French | Primary agent-facing protocol for this fork |
| `README.md` + `references/*` | English | Shared technical grammar reference |
| User-facing shortcut copy in templates | Match the target audience | EN for goldens; FR notes in Locally stub |

`OutputName` values inside plists are always **English** Shortcuts labels.

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

```
~/.hermes/skills/shortcuts-generator/
├── SKILL.md
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── data/
│   ├── wf_actions.json          # SSOT: 427 WF*Action ids
│   └── appintents.json          # SSOT: 154 curated AppIntent ids
├── references/                  # Grammar + playbooks
├── scripts/
│   ├── sign_shortcut.sh
│   ├── validate.sh
│   └── check_shortcut_grammar.py  # 10/10 prep (deeper grammar)
├── templates/
│   ├── hello-world.shortcut.xml
│   ├── shortcut-skeleton.plist
│   ├── locally-obsidian.stub.xml
│   └── examples/                # Importable goldens 01–08
├── fixtures/attested/           # 10/10: macOS/iOS import attestations
└── .github/workflows/validate.yml
```

### 4. Reload Hermes skills

Restart Hermes or reload skills so the new skill is detected.

## Usage

Once installed, ask Hermes to create a shortcut:

- "Create a shortcut that shows the current weather"
- "Build a shortcut that takes text input and shows it"
- "Make a shortcut that opens Safari and navigates to a URL"

Hermes will generate the plist XML, write it to a `.shortcut` file, and sign it so you can import it directly into the Shortcuts app.

## Validation

```bash
./scripts/validate.sh
```

Checks SSOT catalog contracts, XML well-formedness, shell syntax, and grammar heuristics on importable templates (`*.stub.xml` is XML-only).

## What's Included

| File | Description |
|------|-------------|
| `SKILL.md` | Skill definition (FR) |
| `data/wf_actions.json` | SSOT for all 427 WF*Action identifiers |
| `data/appintents.json` | SSOT for curated subset of 154 AppIntent identifiers |
| `references/ACTIONS.md` | WF*Action docs + complete list |
| `references/POWER_ACTIONS.md` | Parameter schemas for 25 priority actions |
| `references/APPINTENTS.md` | Curated subset of 154 AppIntent identifiers |
| `references/FAILURE_MODES.md` | Agent failure playbook |
| `references/PLATFORM_MATRIX.md` | iOS/macOS availability (curated) |
| `references/EXAMPLES.md` | Index of importable goldens |
| `scripts/sign_shortcut.sh` | Signing helper |
| `scripts/validate.sh` | Repo validation |
| `templates/examples/` | Importable golden shortcuts |
| `templates/locally-obsidian.stub.xml` | Non-importable design stub |

## Requirements

- macOS with the `shortcuts` CLI for signing/import
- Hermes Agent
- `xmllint` (libxml2) + `python3` for `./scripts/validate.sh`

## License

MIT — see [LICENSE](LICENSE).
