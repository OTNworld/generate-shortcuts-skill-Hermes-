# Craig Loop fixtures

Broken XML samples for `scripts/craig_loop_lite.py` / `validate_on_write.sh --fix`.

| File | Issue | Expected |
|------|-------|----------|
| `lc-uuid-hello.shortcut.xml` | lowercase UUID hex letters | uppercase → validate PASS |
| `mode-str.shortcut.xml` | `WFControlFlowMode` as `<string>` | `<integer>` → validate PASS |
| `savefile-hello.shortcut.xml` | `is.workflow.actions.savefile` | `documentpicker.save` → validate PASS |
| `remix-in.shortcut.xml` | MCP remix input (hello golden copy) | optional scratch |
| `remix-out*.shortcut.xml` | MCP remix outputs | gitignored / local scratch |

Regenerate:

```bash
# see scripts/craig_loop_lite.py docstring
./scripts/validate_on_write.sh --fix fixtures/craig/<file>
```

These fixtures stay **intentionally broken** in git so CI / `selftest.sh` can prove
`validate_on_write.sh --fix` recovers them. Do not commit the fixed forms.
