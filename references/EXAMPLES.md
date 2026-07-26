# Complete Working Examples

Importable goldens live under [`templates/examples/`](../templates/examples/).
Copy a file, rename to `.shortcut`, sign, then import.

Validate locally:

```bash
./scripts/validate.sh
```

## Example 1: Hello World

Minimal Get Text → Show Result.

- File: [`templates/examples/01-hello-world.shortcut.xml`](../templates/examples/01-hello-world.shortcut.xml)
- Also mirrored as [`templates/hello-world.shortcut.xml`](../templates/hello-world.shortcut.xml)

## Example 2: Ask User for Input

Ask → Get Text (with `attachmentsByRange`) → Show Result.

- File: [`templates/examples/02-ask-input.shortcut.xml`](../templates/examples/02-ask-input.shortcut.xml)

## Example 3: Ask AI (Apple Intelligence)

Ask → Ask LLM → Show Result. Requires Apple Intelligence on device.

- File: [`templates/examples/03-ask-llm.shortcut.xml`](../templates/examples/03-ask-llm.shortcut.xml)

## Example 4: Menu Demo

Choose From Menu with modes `0` / `1` / `2` and shared `GroupingIdentifier`.

- File: [`templates/examples/04-menu.shortcut.xml`](../templates/examples/04-menu.shortcut.xml)

## Example 5: Weather + AI Report

Current weather → build prompt → Ask LLM → Show Result.

- File: [`templates/examples/05-weather-ai.shortcut.xml`](../templates/examples/05-weather-ai.shortcut.xml)

## Example 6: Conditional

Ask Number → If / Otherwise / End If.

- File: [`templates/examples/06-conditional.shortcut.xml`](../templates/examples/06-conditional.shortcut.xml)

## Example 7: Repeat Count

Repeat Count (3) → Get Text → End Repeat → Show Result.

- File: [`templates/examples/07-repeat-count.shortcut.xml`](../templates/examples/07-repeat-count.shortcut.xml)

## Example 8: Repeat Each

List → Repeat Each → End Repeat → Show Result.

- File: [`templates/examples/08-repeat-each.shortcut.xml`](../templates/examples/08-repeat-each.shortcut.xml)

## Community goldens (vendored MIT)

Real-world examples from peer projects — see [`templates/examples/community/`](../templates/examples/community/) and [`ECOSYSTEM.md`](./ECOSYSTEM.md).

| File | Title |
|------|-------|
| [`09-url-cleaner.shortcut.xml`](../templates/examples/community/09-url-cleaner.shortcut.xml) | URL Cleaner |
| [`10-parse-json-feed.shortcut.xml`](../templates/examples/community/10-parse-json-feed.shortcut.xml) | Parse JSON Feed |
| [`11-invert-names.shortcut.xml`](../templates/examples/community/11-invert-names.shortcut.xml) | Invert Names |
| [`12-days-in-a-month.shortcut.xml`](../templates/examples/community/12-days-in-a-month.shortcut.xml) | Days In a Month |
| [`13-electricity-price.shortcut.xml`](../templates/examples/community/13-electricity-price.shortcut.xml) | Electricity Price |

Upstream catalog index: [`data/external/viticci-playground-goldens.index.jsonl`](../data/external/viticci-playground-goldens.index.jsonl).

---

## How to Use These Examples

1. **Copy** an example XML file
2. **Save** with a `.shortcut` extension (e.g. `HelloWorld.shortcut`)
3. **Sign** using the Shortcuts CLI:
   ```bash
   ./scripts/sign_shortcut.sh HelloWorld.shortcut HelloWorld_signed.shortcut
   ```
4. **Import** by double-clicking the signed file or dragging into Shortcuts.app

See also [`FAILURE_MODES.md`](./FAILURE_MODES.md) if import fails.
