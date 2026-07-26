# Craig Loop fixtures

Broken XML samples for `scripts/craig_loop_lite.py` / `validate_on_write.sh --fix`.

| File | Issue | Expected |
|------|-------|----------|
| `lc-uuid-hello.shortcut.xml` | lowercase UUID hex letters | uppercase → validate PASS |
| `mode-str.shortcut.xml` | `WFControlFlowMode` as `<string>` | `<integer>` → validate PASS |

Regenerate:

```bash
# see scripts/craig_loop_lite.py docstring
./scripts/validate_on_write.sh --fix fixtures/craig/<file>
```

These files may be left **fixed** after local tests; re-break before demo if needed.
