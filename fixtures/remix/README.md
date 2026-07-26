# Remix fixtures

Mechanical remix scenarios for `scripts/remix_shortcut.py`.

## hello → Bonjour

```bash
python3 scripts/remix_shortcut.py \
  templates/examples/01-hello-world.shortcut.xml \
  --replace-text "Hello World!" "Bonjour!" \
  --output /tmp/hello-bonjour.shortcut.xml
./scripts/validate_on_write.sh /tmp/hello-bonjour.shortcut.xml
```

Expected run output after sign/import: `Bonjour!`

Do not commit mutated teaching goldens; always `--output` to a temp path in demos.
