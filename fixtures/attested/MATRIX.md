# Attestation matrix

Fill on macOS after sign → import → run. Leave community rows for a second pass if needed.

**Machine:** _(hostname)_  
**macOS:** _(e.g. 15.5)_  
**Shortcuts app build:** _(Shortcuts → Settings / About if available)_  
**Attestor:** _(name)_  
**Date (UTC):** _2026-07-26_

| Golden | macOS | iOS | Shortcuts build | Date (UTC) | Sign | Import | Run | Notes |
|--------|-------|-----|-----------------|------------|------|--------|-----|-------|
| examples/01-hello-world |  | — |  |  |  |  |  |  |
| examples/02-ask-input |  | — |  |  |  |  |  |  |
| examples/03-ask-llm |  | — |  |  |  |  |  |  |
| examples/04-menu |  | — |  |  |  |  |  |  |
| examples/05-weather-ai |  | — |  |  |  |  |  |  |
| examples/06-conditional |  | — |  |  |  |  |  |  |
| examples/07-repeat-count |  | — |  |  |  |  |  |  |
| examples/08-repeat-each |  | — |  |  |  |  |  |  |
| palette/01-ask |  | — |  |  |  |  |  |  |
| palette/02-gettext-show |  | — |  |  |  |  |  |  |
| palette/03-setclipboard |  | — |  |  |  |  |  |  |
| palette/04-url-open |  | — |  |  |  |  |  |  |
| palette/05-list |  | — |  |  |  |  |  |  |
| palette/06-dictionary |  | — |  |  |  |  |  |  |
| palette/07-variables |  | — |  |  |  |  |  |  |
| palette/08-downloadurl |  | — |  |  |  |  |  |  |
| palette/09-comment-nothing |  | — |  |  |  |  |  |  |
| palette/10-count |  | — |  |  |  |  |  |  |
| palette/11-choosefromlist |  | — |  |  |  |  |  |  |
| palette/12-delay |  | — |  |  |  |  |  |  |
| community/09-url-cleaner |  | — |  |  |  |  |  | optional |
| community/10-parse-json-feed |  | — |  |  |  |  |  | optional |
| community/11-invert-names |  | — |  |  |  |  |  | optional |
| community/12-days-in-a-month |  | — |  |  |  |  |  | optional |
| community/13-electricity-price |  | — |  |  |  |  |  | optional |

## Hashes (unsigned XML only)

Generate with:

```bash
./scripts/attest_local.sh --hash-only
```

Paste output below or keep `fixtures/attested/hashes.sha256` (gitignored signed binaries stay out of git).

```
# paste shasum -a 256 lines here
```

## Pass criteria for 10/10 skill

- [ ] All `examples/01`–`08` : Sign=OK, Import=OK, Run=OK (or documented FAIL with cause)
- [ ] All `palette/01`–`12` : Sign=OK, Import=OK (Run optional for delay/downloadurl network)
- [ ] At least 2 `community/*` : Import=OK
- [ ] `hashes.sha256` committed or pasted above
- [ ] Bump `SKILL.md` → `1.9.0` + CHANGELOG entry `Attested on macOS …`
