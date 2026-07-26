# Platform Matrix (Curated)

Availability for the actions agents use most. **Curated estimates** — always verify
on the target OS build. Prefer this list before freelancing obscure IDs.

Legend: `Y` = typically available, `L` = limited / version-dependent, `N` = usually absent.

| Action ID (`is.workflow.actions.*`) | iOS | macOS | Notes |
|-------------------------------------|-----|-------|-------|
| ask | Y | Y | Prefer over share sheet on Mac |
| gettext | Y | Y | |
| showresult | Y | Y | |
| setclipboard | Y | Y | |
| openurl | Y | Y | |
| openapp | Y | Y | Bundle id / app name differ by OS |
| url | Y | Y | |
| list | Y | Y | |
| dictionary | Y | Y | |
| getvalueforkey | Y | Y | Prefer over legacy `getdictionaryvalue` |
| setvariable / getvariable | Y | Y | |
| choosefrommenu | Y | Y | Needs GroupingIdentifier |
| conditional | Y | Y | |
| repeat.count / repeat.each | Y | Y | |
| downloadurl | Y | Y | See ACTIONS HTTP section |
| documentpicker.open / .save | Y | Y | Replaces invalid `savefile` |
| file.append | Y | Y | |
| runworkflow | Y | Y | |
| share | Y | L | UI differs |
| shareextension | Y | N/L | Prefer `ask` on Mac |
| appintentexecution | Y | L | Intent must exist on Mac |
| askllm | L | L | Apple Intelligence required |
| weather.currentconditions | Y | Y | Location permission |
| getclipboard | Y | Y | |
| notification | Y | Y | |
| nothing | Y | Y | Useful inside loops |
| comment | Y | Y | |
| delay | Y | Y | |
| exit | Y | Y | |
| gettextfrompdf | Y | Y | |
| selectphoto | Y | L | |
| takephoto | Y | N | Hardware |
| getcurrentlocation | Y | L | Permissions |
| runshellscript | N | Y | macOS only |
| runosascript | N | Y | macOS only |
| getselectedfinderfiles | N | Y | macOS only |
| revealfiles | N | Y | macOS only |
| alert | Y | Y | Teaching / UI |
| appendvariable | Y | Y | |
| choosefromlist | Y | Y | Interactive (UI) |
| date / format.date | Y | Y | |
| detect.text / detect.link / detect.dictionary | Y | Y | |
| filter.files / filter.calendarevents | Y | Y | Community goldens |
| getitemfromlist | Y | Y | |
| gettraveltime | Y | L | Maps / location |
| geturlcomponent | Y | Y | |
| math / number | Y | Y | |
| openin | Y | L | |
| previewdocument | Y | Y | Files preview |
| properties.contacts | Y | L | |
| runapplescript | N | Y | Prefer `runosascript` naming in SSOT |
| safari.geturl | Y | L | Safari |
| setitemname | Y | Y | |
| text.match / text.match.getgroup / text.replace / text.split | Y | Y | Regex / text |

## Guidance for agents

1. Default to the **Y/Y** rows above for cross-platform shortcuts
2. If targeting Mac only, shell/OSA/Finder actions are fine
3. If import fails with “unknown action”, check this matrix then export a POC from Shortcuts.app
4. Full ID dump: `data/wf_actions.json` (no per-OS flags yet — planned for 10/10)
