# Remix fixtures

Mechanical remix scenarios for `scripts/remix_shortcut.py`.
Covered by `./scripts/selftest.sh` and `tests/test_linux10.py`.

## hello → Bonjour (I/O pair)

| File | Role |
|------|------|
| `hello-bonjour.input.xml` | Copy of teaching hello-world |
| `hello-bonjour.expected.xml` | After `--replace-text "Hello World!" "Bonjour!"` |

```bash
python3 scripts/remix_shortcut.py \
  fixtures/remix/hello-bonjour.input.xml \
  --replace-text "Hello World!" "Bonjour!" \
  --output /tmp/hello-bonjour.shortcut.xml
./scripts/validate_on_write.sh /tmp/hello-bonjour.shortcut.xml
```

Expected run output after sign/import: `Bonjour!`

## Structural: insert delay + rename

```bash
python3 scripts/remix_shortcut.py \
  templates/examples/01-hello-world.shortcut.xml \
  --insert-action 1 '{"identifier":"delay","parameters":{"WFDelayTime":1}}' \
  --set-name "Hello Remix" \
  --output /tmp/hello-remix.shortcut.xml
./scripts/validate_on_write.sh /tmp/hello-remix.shortcut.xml
python3 scripts/remix_shortcut.py /tmp/hello-remix.shortcut.xml --list-actions
```

Do not commit mutated teaching goldens; demos always use `--output` to a temp path.
