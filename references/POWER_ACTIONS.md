# Power Actions (parameter schemas)

Deep parameter keys for the **25 actions** agents should prefer first.
Full ID catalog: [`data/wf_actions.json`](../data/wf_actions.json). Grammar: [`PARAMETER_TYPES.md`](./PARAMETER_TYPES.md).

Prefix all identifiers with `is.workflow.actions.` unless noted.

## 1. ask

| Key | Type | Notes |
|-----|------|-------|
| `UUID` | string | Required if output is referenced |
| `WFAskActionPrompt` | string | Prompt text |
| `WFInputType` | string | `Text`, `Number`, `URL`, `Date`, … |
| `WFAskActionDefaultAnswer` | string | Optional |

**OutputName:** `Provided Input`

## 2. gettext

| Key | Type | Notes |
|-----|------|-------|
| `UUID` | string | |
| `WFTextActionText` | string **or** `WFTextTokenString` dict | Use dict when embedding `￼` |

**OutputName:** `Text`

## 3. showresult

| Key | Type | Notes |
|-----|------|-------|
| `Text` | string or `WFTextTokenString` | Body to display |

## 4. setclipboard

| Key | Type | Notes |
|-----|------|-------|
| `WFItems` | `WFTextTokenString` / attachment | Content to copy |
| `WFLocalOnly` | boolean | Optional |
| `WFExpirationDate` | date dict | Optional |

## 5. openurl

| Key | Type | Notes |
|-----|------|-------|
| `WFInput` | URL attachment / string | URL to open |

## 6. openapp

| Key | Type | Notes |
|-----|------|-------|
| `WFAppIdentifier` / app params | string | Bundle id style varies by OS |

## 7. url

| Key | Type | Notes |
|-----|------|-------|
| `WFURLActionURL` | string | Produce a URL item |

**OutputName:** often `URL`

## 8. list

| Key | Type | Notes |
|-----|------|-------|
| `UUID` | string | |
| `WFItems` | array of strings/dicts | |

**OutputName:** `List`

## 9. dictionary

| Key | Type | Notes |
|-----|------|-------|
| `UUID` | string | |
| `WFItems` | dictionary serialization | See PARAMETER_TYPES |

## 10. getvalueforkey

Canonical id for “Get Dictionary Value” (prefer this over legacy `getdictionaryvalue`).

| Key | Type | Notes |
|-----|------|-------|
| `WFDictionaryKey` | string or text token | Key to read |
| `WFGetDictionaryValueType` | string | e.g. `Value`, `All Keys` |
| `WFInput` | attachment | Dictionary source |
| `UUID` | string | |

## 11. setvariable

| Key | Type | Notes |
|-----|------|-------|
| `WFVariableName` | string | Name |
| `WFInput` | attachment | Value |

## 12. getvariable

| Key | Type | Notes |
|-----|------|-------|
| `WFVariable` | variable attachment | Named variable |

## 13. choosefrommenu

| Key | Type | Notes |
|-----|------|-------|
| `GroupingIdentifier` | UUID | Shared across start/cases/end |
| `WFControlFlowMode` | integer | `0` start, `1` case, `2` end |
| `WFMenuPrompt` | string | Start only |
| `WFMenuItems` | array | Start only |
| `WFMenuItemTitle` | string | Case only — must match items |

## 14. conditional

| Key | Type | Notes |
|-----|------|-------|
| `GroupingIdentifier` | UUID | |
| `WFControlFlowMode` | integer | `0` if, `1` otherwise, `2` end |
| `WFCondition` | integer | Operator enum |
| `WFNumberValue` / text value | varies | RHS |
| `WFInput` | attachment | LHS |

## 15. repeat.count

| Key | Type | Notes |
|-----|------|-------|
| `GroupingIdentifier` | UUID | |
| `WFControlFlowMode` | integer | `0` start, `2` end |
| `WFRepeatCount` | integer | Start only |
| `UUID` | string | On **end** — for Repeat Index / Results |

## 16. repeat.each

| Key | Type | Notes |
|-----|------|-------|
| `GroupingIdentifier` | UUID | |
| `WFControlFlowMode` | integer | `0` / `2` |
| `WFInput` | list attachment | Start only |
| `UUID` | string | On **end** — Repeat Item / Results |

## 17. downloadurl

| Key | Type | Notes |
|-----|------|-------|
| `WFURL` | URL | |
| `WFHTTPMethod` | string | GET/POST/… |
| `WFHTTPBodyType` | string | Optional |
| `WFHTTPHeaders` | dictionary | Optional |
| `WFFormValues` / JSON body | varies | See ACTIONS HTTP section |

## 18. documentpicker.open

| Key | Type | Notes |
|-----|------|-------|
| picker / path params | varies | Open file |

## 19. documentpicker.save

| Key | Type | Notes |
|-----|------|-------|
| destination params | varies | **Use this**, not `savefile` |

## 20. file.append

| Key | Type | Notes |
|-----|------|-------|
| file target + text | varies | Append to file |

## 21. runworkflow

| Key | Type | Notes |
|-----|------|-------|
| workflow reference | varies | Run another shortcut |
| input attachment | optional | |

## 22. shareextension

| Key | Type | Notes |
|-----|------|-------|
| input from share sheet | — | **Limited on macOS** — prefer `ask` |

## 23. askllm

| Key | Type | Notes |
|-----|------|-------|
| `UUID` | string | |
| `WFLLMModel` | string | e.g. `Apple Intelligence` |
| `WFGenerativeResultType` | string | e.g. `Text` |
| `WFLLMPrompt` | `WFTextTokenString` | Prompt with optional `￼` |

**OutputName:** often `Response`

## 24. weather.currentconditions

| Key | Type | Notes |
|-----|------|-------|
| `UUID` | string | |
| location params | optional | May use current location |

**OutputName:** `Weather Conditions`

## 26. notification

| Key | Type | Notes |
|-----|------|-------|
| `WFInput` | attachment | Body text (magic input) |

## 27. number

| Key | Type | Notes |
|-----|------|-------|
| `UUID` | string | |
| `WFNumberActionNumber` | real/integer | Literal number |

**OutputName:** `Number`

## 28. speaktext

| Key | Type | Notes |
|-----|------|-------|
| `WFInput` | attachment | Text to speak |
| `WFSpeakTextWait` | boolean | Wait until finished |

---

## Agent rule

If an action is not in this power list, either:
1. Look up the ID in `data/wf_actions.json` and keep parameters minimal, or
2. Export a working POC from Shortcuts.app and diff parameters — do not invent keys.
