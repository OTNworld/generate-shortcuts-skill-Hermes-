# Shortcuts Generator Skill for Hermes

A Hermes skill for AI-assisted generation of macOS/iOS Shortcuts. Create valid `.shortcut` plist files that can be signed and imported into Apple's Shortcuts app.

## Language policy

| Surface | Language | Why |
|---------|----------|-----|
| `SKILL.md` (Hermes prompts / workflow) | French | Primary agent-facing protocol for this fork |
| `README.md` + `references/*` | English | Shared technical grammar reference |
| User-facing shortcut copy in templates | Match the target audience | EN for goldens; FR optional vault notes |

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
│   ├── wf_actions.json
│   ├── appintents.json
│   ├── sources.json                 # External repo registry
│   └── external/                    # Remote corpus indexes
├── references/                      # Grammar + playbooks + ECOSYSTEM.md
├── templates/examples/              # Teaching goldens + community/
├── THIRD_PARTY_NOTICES.md
├── scripts/
│   ├── sign_shortcut.sh
│   ├── validate.sh
│   └── check_shortcut_grammar.py  # 10/10 prep (deeper grammar)
├── templates/
│   ├── hello-world.shortcut.xml
│   ├── shortcut-skeleton.plist
│   ├── locally-obsidian.stub.xml  # abandoned historical stub
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

**Agent map (≤2 min):** [`references/AGENT_ENTRY.md`](references/AGENT_ENTRY.md)  
**Linux 10/10 track:** [`references/LINUX_10_CHECKLIST.md`](references/LINUX_10_CHECKLIST.md)  
**Mac 10/10 track (device):** [`references/MAC_10_CHECKLIST.md`](references/MAC_10_CHECKLIST.md)  
**Horizon packages:** [`horizon/README.md`](horizon/README.md)  
**Release:** [`references/RELEASE.md`](references/RELEASE.md) · `./scripts/cut_release.sh`  
**Product direction (companion app / Siri / local-model marketplace):** [`references/HORIZON.md`](references/HORIZON.md). The Locally→Obsidian stub track is abandoned.

## Local finalize (Mac → 10/10)

See [`LOCAL_FINALIZE.md`](LOCAL_FINALIZE.md) and `./scripts/attest_local.sh --auto`.

**Differentiation:** this skill treats **macOS sign → import UI → run → `results.json`** as first-class.
Peer playgrounds often lead on remix/ToolKit size; we lead on **attested, reproducible Mac delivery**.
Remix lean: `references/REMIX.md` + `scripts/remix_shortcut.py`. After every plist edit: `scripts/validate_on_write.sh`.

## Validation

```bash
./scripts/validate.sh
./scripts/validate_on_write.sh templates/examples/01-hello-world.shortcut.xml
```

Checks SSOT catalog contracts, XML well-formedness, shell syntax, and grammar heuristics on importable templates (`*.stub.xml` is XML-only).

## What's Included

| File | Description |
|------|-------------|
| `SKILL.md` | Skill definition (FR) |
| `data/wf_actions.json` | SSOT for all 446 WF*Action identifiers |
| `data/appintents.json` | SSOT for curated subset of 168 AppIntent identifiers |
| `references/ACTIONS.md` | WF*Action docs + complete list |
| `references/POWER_ACTIONS.md` | Parameter schemas for 25 priority actions |
| `references/APPINTENTS.md` | Curated subset of 168 AppIntent identifiers |
| `references/FAILURE_MODES.md` | Agent failure playbook |
| `references/PLATFORM_MATRIX.md` | iOS/macOS availability (curated) |
| `references/EXAMPLES.md` | Index of importable goldens |
| `scripts/sign_shortcut.sh` | Signing helper |
| `scripts/validate.sh` | Repo validation |
| `data/sources.json` | Registry of external repos / corpora |
| `references/ECOSYSTEM.md` | How we link, index, and selectively vendor peers |
| `references/URL_SCHEMES.md` | `shortcuts://` + x-callback-url |
| `templates/examples/community/` | MIT-vendored real-world goldens |
| `templates/palette/` | 16 minimal power-action starters |
| `references/STARTER_PALETTE.md` | Palette index |
| `scripts/extract_shortcut.sh` | Binary/XML shortcut → inspectable XML |
| `scripts/render_refs.py` | Regenerate catalog fences from SSOT |
| `fixtures/attested/MAC_HANDOFF.md` | Later: Mac sign/import attestation |
| `THIRD_PARTY_NOTICES.md` | Attribution for vendored/cited material |

## Requirements

- macOS with the `shortcuts` CLI for signing/import
- Hermes Agent
- `xmllint` (libxml2) + `python3` for `./scripts/validate.sh`

## License

MIT — see [LICENSE](LICENSE).
