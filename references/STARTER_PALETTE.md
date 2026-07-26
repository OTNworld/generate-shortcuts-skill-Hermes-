# Starter palette

Minimal, importable XML demonstrating the actions agents should prefer first.
Schemas: [`POWER_ACTIONS.md`](./POWER_ACTIONS.md). Control-flow goldens live under
[`templates/examples/`](../templates/examples/) (04 menu, 06 conditional, 07–08 repeats).

| File | Actions shown |
|------|----------------|
| [`01-ask.shortcut.xml`](../templates/palette/01-ask.shortcut.xml) | ask → showresult |
| [`02-gettext-show.shortcut.xml`](../templates/palette/02-gettext-show.shortcut.xml) | gettext → showresult |
| [`03-setclipboard.shortcut.xml`](../templates/palette/03-setclipboard.shortcut.xml) | gettext → setclipboard |
| [`04-url-open.shortcut.xml`](../templates/palette/04-url-open.shortcut.xml) | url → openurl |
| [`05-list.shortcut.xml`](../templates/palette/05-list.shortcut.xml) | list → showresult |
| [`06-dictionary.shortcut.xml`](../templates/palette/06-dictionary.shortcut.xml) | dictionary → getvalueforkey → showresult |
| [`07-variables.shortcut.xml`](../templates/palette/07-variables.shortcut.xml) | setvariable / getvariable |
| [`08-downloadurl.shortcut.xml`](../templates/palette/08-downloadurl.shortcut.xml) | url → downloadurl → showresult |
| [`09-comment-nothing.shortcut.xml`](../templates/palette/09-comment-nothing.shortcut.xml) | comment + nothing |
| [`10-count.shortcut.xml`](../templates/palette/10-count.shortcut.xml) | list → count |
| [`11-choosefromlist.shortcut.xml`](../templates/palette/11-choosefromlist.shortcut.xml) | list → choosefromlist |
| [`12-delay.shortcut.xml`](../templates/palette/12-delay.shortcut.xml) | delay → showresult |

**Agent rule:** compose from this palette + `templates/examples/0{4,6,7,8}*.xml` before freelancing obscure action parameters. If unsure, export a POC from Shortcuts.app and run `scripts/extract_shortcut.sh`.
