# Attestation matrix

Filled on macOS after automated sign → import UI → run (`./scripts/attest_local.sh --auto` / helpers).

**Machine:** MacStudio-de-paul.local  
**macOS:** 26.5.2 (25F84)  
**Shortcuts app build:** _(UI FR — Raccourcis)_  
**Attestor:** ps  
**Date (UTC):** 2026-07-26  
**Automation:** `import_shortcut_ui.sh` (Return CTA) + `run_shortcut_attest.sh`

| Golden | macOS | iOS | Shortcuts build | Date (UTC) | Sign | Import | Run | Notes |
|--------|-------|-----|-----------------|------------|------|--------|-----|-------|
| examples/01-hello-world | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK | `Hello World!` |
| examples/02-ask-input | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK | headless via `inputs/02-ask-input.txt` |
| examples/03-ask-llm | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | interactive / AI (ENV) |
| examples/04-menu | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | interactive (UI) |
| examples/05-weather-ai | 26.5.2 | — |  | 2026-07-26 | OK | OK | FAIL | ENV: Apple Intelligence unavailable (not pure NET) |
| examples/06-conditional | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK | fixed golden; library alias `06-conditional-v2_signed` |
| examples/07-repeat-count | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| examples/08-repeat-each | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| palette/01-ask | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK | headless via `inputs/01-ask.txt` |
| palette/02-gettext-show | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| palette/03-setclipboard | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| palette/04-url-open | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK | `--include-network` |
| palette/05-list | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| palette/06-dictionary | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK | fixed `getvalueforkey`; alias `06-dictionary-fixed_signed` |
| palette/07-variables | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| palette/08-downloadurl | 26.5.2 | — |  | 2026-07-26 | OK | OK | FAIL | NET flaky timeout (apple.com); structure aligned electricity-price |
| palette/09-comment-nothing | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| palette/10-count | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| palette/11-choosefromlist | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | interactive (UI) |
| palette/12-delay | 26.5.2 | — |  | 2026-07-26 | OK | OK | OK |  |
| community/09-url-cleaner | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | Import OK (C1) |
| community/10-parse-json-feed |  | — |  |  |  |  |  | optional |
| community/11-invert-names | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | Import OK (C1) |
| community/12-days-in-a-month |  | — |  |  |  |  |  | optional |
| community/13-electricity-price |  | — |  |  |  |  |  | optional |
| community/14-preview-folder-contents | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | V3 files gap |
| community/15-masto-redirect | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | V3 HTTP gap |
| community/16-calendar-locations | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | V3 calendar gap |
| examples/09-share-sheet-input | 26.5.2 | — |  | 2026-07-26 | OK | OK | — | teaching Share Sheet / ActionExtension |

## Hashes (unsigned XML only)

```
603cf634dbac3f3b0b5516bcf24161d2ea90636026f7ef2a2712b4df59304e31  templates/examples/01-hello-world.shortcut.xml
e152d1808b964c95189ef881509e530fdaa9acdfa0ab39d80d2dce2c1b166cde  templates/examples/02-ask-input.shortcut.xml
6236b4facdb680593df33c22b83438fbd892c95f004bbd56c2e8ae5c1eb39fc9  templates/examples/03-ask-llm.shortcut.xml
757fe0d60e70ea869e239ead27fab5717e5dde878729148763c00f7aafacac31  templates/examples/04-menu.shortcut.xml
f620ef58b0e1720de6d8d114c2661eb227299b355f127b2a182f116a1a4e2024  templates/examples/05-weather-ai.shortcut.xml
a0401ac96d7e8fd93694dc06634bba938fd874ab4b4cf742639f56a7487d8553  templates/examples/06-conditional.shortcut.xml
86f8856a431824b68599370e55b56cb49c217ad851dbf8defb0206245e5ea860  templates/examples/07-repeat-count.shortcut.xml
cfd490ca3ab171be3c298175dca3804a8f6fd6eb29a1d28c14297f99124316d3  templates/examples/08-repeat-each.shortcut.xml
88b47da8e11fc3501b34808a61ba74d12806c06e04f13996494d78d2702aa7db  templates/palette/01-ask.shortcut.xml
315b641efcfa6d00ddb0618fb91685ce31ce6e16ff56c221b47f638f693ca59d  templates/palette/02-gettext-show.shortcut.xml
8a9494b1b92d9b40e82c29b9e28b75c88b08ae53b2c03bb8249a284c28ebd8f2  templates/palette/03-setclipboard.shortcut.xml
160c042072c783a7c792f49fcef12669d1529909a04724b070938d5c61a6d37d  templates/palette/04-url-open.shortcut.xml
19a56b49eb33ca67b65a9cef0db5ec75f88c17b2c4e0d543b683eef05d670581  templates/palette/05-list.shortcut.xml
4edbf7ae91eb6927e4aea3077adb287daff9927d474240330637c9bfcf13c46b  templates/palette/06-dictionary.shortcut.xml
875f41f6544c5241664d9a101e825a2f9fc9a9e2785e1d032b261443ac7e7965  templates/palette/07-variables.shortcut.xml
cffe5c00c6e063ba44a0d8739dbdea2a8e3c42f166727a12b018b86009669c6a  templates/palette/08-downloadurl.shortcut.xml
3c513224c1542e5435c9d7971f14329aada061c8329f1eae474b72b046cc31f4  templates/palette/09-comment-nothing.shortcut.xml
db4632387257a71c4be232bcb8de27d22e539f7719cbe318b1ac21d2548ca453  templates/palette/10-count.shortcut.xml
3ab04716eed4fd633dcbb9edd109ef35cbd3e30d459c54e7329f4470421c4691  templates/palette/11-choosefromlist.shortcut.xml
b29ea5bb221f31fe038ce5c0e20b3c78cb644aa86ffa7e881e621704e4f4cc38  templates/palette/12-delay.shortcut.xml
```

Also kept in `fixtures/attested/hashes.sha256`.

## Pass criteria for 10/10 skill

- [x] All `examples/01`–`08` : Sign=OK, Import=OK, Run=OK (or documented skip UI/NET/ENV)
- [x] All `palette/01`–`12` : Sign=OK, Import=OK (Run OK or categorized skip)
- [x] At least 2 `community/*` : Import=OK (`09-url-cleaner`, `11-invert-names`)
- [x] `hashes.sha256` committed or pasted above
- [x] Bump `SKILL.md` → `1.9.0` + CHANGELOG entry `Attested on macOS …`
- [x] Machine-readable `fixtures/attested/results.json` + ask headless inputs (Mac max, no iOS)

See also: `import_report.tsv`, `run_report.tsv`, `inputs/`.
