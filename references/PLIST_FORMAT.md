# Shortcut Plist Format

Complete documentation of the `.shortcut` file structure.

**Related docs:**
- [ACTIONS.md](./ACTIONS.md) - Action identifiers and parameters
- [FILTERS.md](./FILTERS.md) - Content filters for Find/Filter actions
- [PARAMETER_TYPES.md](./PARAMETER_TYPES.md) - All parameter value types
- [VARIABLES.md](./VARIABLES.md) - Variable references and outputs
- [CONTROL_FLOW.md](./CONTROL_FLOW.md) - Conditionals, loops, menus

## Root Structure

A `.shortcut` file is a binary plist (can be written as XML, then converted). The root is a dictionary with these keys:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- REQUIRED -->
    <key>WFWorkflowActions</key>
    <array>
        <!-- Array of action dictionaries -->
    </array>

    <!-- REQUIRED - Version info -->
    <key>WFWorkflowClientVersion</key>
    <string>2700.0.4</string>
    <key>WFWorkflowClientRelease</key>
    <string>26A0000a</string>
    <key>WFWorkflowMinimumClientVersion</key>
    <integer>900</integer>
    <key>WFWorkflowMinimumClientVersionString</key>
    <string>900</string>

    <!-- REQUIRED - Icon -->
    <key>WFWorkflowIcon</key>
    <dict>
        <key>WFWorkflowIconGlyphNumber</key>
        <integer>59511</integer>
        <key>WFWorkflowIconStartColor</key>
        <integer>4282601983</integer>
    </dict>

    <!-- OPTIONAL - Shortcut name (displayed in app) -->
    <key>WFWorkflowName</key>
    <string>My Shortcut</string>

    <!-- OPTIONAL - Usually empty arrays -->
    <key>WFWorkflowHasOutputFallback</key>
    <false/>
    <key>WFWorkflowImportQuestions</key>
    <array/>
    <key>WFWorkflowOutputContentItemClasses</key>
    <array/>
    <key>WFWorkflowTypes</key>
    <array/>

    <!-- OPTIONAL - Input content types accepted -->
    <key>WFWorkflowInputContentItemClasses</key>
    <array>
        <string>WFStringContentItem</string>
        <string>WFURLContentItem</string>
        <!-- ... more content types ... -->
    </array>
</dict>
</plist>
```

## Root Keys Reference

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `WFWorkflowActions` | Array | Yes | Array of action dictionaries |
| `WFWorkflowClientVersion` | String | Yes | Client version (e.g., "2700.0.4") |
| `WFWorkflowClientRelease` | String | No | Release identifier |
| `WFWorkflowMinimumClientVersion` | Integer | Yes | Minimum version number (900+) |
| `WFWorkflowMinimumClientVersionString` | String | Yes | String version of minimum |
| `WFWorkflowIcon` | Dict | Yes | Icon configuration |
| `WFWorkflowName` | String | No | Display name |
| `WFWorkflowHasOutputFallback` | Boolean | No | Has output fallback |
| `WFWorkflowImportQuestions` | Array | No | Import-time questions |
| `WFWorkflowInputContentItemClasses` | Array | No | Accepted input types |
| `WFWorkflowOutputContentItemClasses` | Array | No | Output types |
| `WFWorkflowTypes` | Array | No | Where the shortcut appears (see below) |

### `WFWorkflowTypes` values (common)

From classic format references (verify on current OS):

| Value | Meaning |
|-------|---------|
| `ActionExtension` | Show in Share Sheet |
| `MenuBar` | Keep in Menu Bar (Mac) |
| `QuickActions` | Use as Quick Action (Mac) |
| `NCWidget` | Notification Center / widget surfaces (legacy naming) |
| `Watch` / `WatchKit` | Apple Watch availability (naming varies by OS era) |
| `Sleep` | Sleep Focus / Sleep Mode surfaces |

### Import questions shape

Each `WFWorkflowImportQuestions` item typically includes `ActionIndex`, `Category`
(often `Parameter`), `ParameterKey`, `Text`, and optional `DefaultValue`.

## Icon Configuration

```xml
<key>WFWorkflowIcon</key>
<dict>
    <key>WFWorkflowIconGlyphNumber</key>
    <integer>59511</integer>
    <key>WFWorkflowIconStartColor</key>
    <integer>4282601983</integer>
</dict>
```

### Common Glyph Numbers

| Glyph | Number | Description |
|-------|--------|-------------|
| Globe | 59511 | Default globe icon |
| Star | 59446 | Star icon |
| Heart | 59448 | Heart icon |
| Gear | 59458 | Settings gear |
| Document | 59493 | Document icon |
| Folder | 59495 | Folder icon |
| Play | 59477 | Play button |
| Message | 59412 | Message bubble |

### Color Values

Icon tints are stored as **RGBA-8** integers. Example: `4282601983` → `0xFF4351FF`
(`RRGGBBAA`). Values below come from the classic
[sebj/iOS-Shortcuts-Reference](https://github.com/sebj/iOS-Shortcuts-Reference)
table (liable to change across OS versions):

| Color | Hex (RRGGBBAA) | Integer |
|-------|----------------|--------:|
| Red | `0xFF4351FF` | 4282601983 |
| Dark Orange | `0xFD6631FF` | 4251333119 |
| Orange | `0xFE9949FF` | 4271458815 |
| Yellow | `0xFEC418FF` | 4274264319 |
| Green | `0xFFD426FF` | 4292093695 |
| Teal | `0x19BD03FF` | 431817727 |
| Light Blue | `0x55DAE1FF` | 1440408063 |
| Blue | `0x1B9AF7FF` | 463140863 |
| Dark Blue | `0x3871DEFF` | 946986751 |
| Violet | `0x7B72E9FF` | 2071128575 |
| Purple | `0xDB49D8FF` | 3679049983 |
| Pink | `0xED4694FF` | 3980825855 |
| Taupe | `0xB4B2A9FF` | 3031607807 |
| Gray | `0xA9A9A9FF` | 2846468607 |
| Dark Gray / Black | `0x000000FF` | 255 |

Skill templates historically use **Red** `4282601983` as the default glyph tint
(not the “Blue” row). Verify against a fresh Shortcuts.app export when matching UI.

Helper (no Viticci clone):

```bash
python3 scripts/shortcut_icon.py --list
python3 scripts/shortcut_icon.py --glyph Document --color Blue --xml
```

## Action Structure

Each action in `WFWorkflowActions` is a dictionary:

```xml
<dict>
    <key>WFWorkflowActionIdentifier</key>
    <string>is.workflow.actions.showresult</string>
    <key>WFWorkflowActionParameters</key>
    <dict>
        <!-- Action-specific parameters -->
        <key>UUID</key>
        <string>A1B2C3D4-E5F6-7890-ABCD-EF1234567890</string>
        <!-- ... more parameters ... -->
    </dict>
</dict>
```

### Action Keys

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `WFWorkflowActionIdentifier` | String | Yes | Action identifier (e.g., `is.workflow.actions.showresult`) |
| `WFWorkflowActionParameters` | Dict | Yes | Action configuration |

### Common Parameter Keys

| Key | Type | Description |
|-----|------|-------------|
| `UUID` | String | Unique ID for referencing this action's output |
| `GroupingIdentifier` | String | Links control flow actions (repeat, if, menu) |
| `WFControlFlowMode` | Integer | 0=start, 1=middle, 2=end |

## Input Content Item Classes

These define what input types the shortcut accepts:

```xml
<key>WFWorkflowInputContentItemClasses</key>
<array>
    <string>WFAppStoreAppContentItem</string>
    <string>WFArticleContentItem</string>
    <string>WFContactContentItem</string>
    <string>WFDateContentItem</string>
    <string>WFEmailAddressContentItem</string>
    <string>WFGenericFileContentItem</string>
    <string>WFImageContentItem</string>
    <string>WFiTunesProductContentItem</string>
    <string>WFLocationContentItem</string>
    <string>WFDCMapsLinkContentItem</string>
    <string>WFAVAssetContentItem</string>
    <string>WFPDFContentItem</string>
    <string>WFPhoneNumberContentItem</string>
    <string>WFRichTextContentItem</string>
    <string>WFSafariWebPageContentItem</string>
    <string>WFStringContentItem</string>
    <string>WFURLContentItem</string>
</array>
```

## Binary vs XML Plist

Shortcuts are stored as binary plists but can be created as XML:

```bash
# Convert XML to binary (optional - signing handles this)
plutil -convert binary1 MyShortcut.shortcut

# Convert binary to XML (for debugging)
plutil -convert xml1 MyShortcut.shortcut
```

The `shortcuts sign` command accepts both formats.

## Complete Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>WFWorkflowActions</key>
    <array>
        <dict>
            <key>WFWorkflowActionIdentifier</key>
            <string>is.workflow.actions.gettext</string>
            <key>WFWorkflowActionParameters</key>
            <dict>
                <key>UUID</key>
                <string>11111111-1111-1111-1111-111111111111</string>
                <key>WFTextActionText</key>
                <string>Hello World!</string>
            </dict>
        </dict>
        <dict>
            <key>WFWorkflowActionIdentifier</key>
            <string>is.workflow.actions.showresult</string>
            <key>WFWorkflowActionParameters</key>
            <dict>
                <key>Text</key>
                <dict>
                    <key>Value</key>
                    <dict>
                        <key>attachmentsByRange</key>
                        <dict>
                            <key>{0, 1}</key>
                            <dict>
                                <key>OutputName</key>
                                <string>Text</string>
                                <key>OutputUUID</key>
                                <string>11111111-1111-1111-1111-111111111111</string>
                                <key>Type</key>
                                <string>ActionOutput</string>
                            </dict>
                        </dict>
                        <key>string</key>
                        <string>￼</string>
                    </dict>
                    <key>WFSerializationType</key>
                    <string>WFTextTokenString</string>
                </dict>
            </dict>
        </dict>
    </array>
    <key>WFWorkflowClientVersion</key>
    <string>2700.0.4</string>
    <key>WFWorkflowHasOutputFallback</key>
    <false/>
    <key>WFWorkflowIcon</key>
    <dict>
        <key>WFWorkflowIconGlyphNumber</key>
        <integer>59511</integer>
        <key>WFWorkflowIconStartColor</key>
        <integer>4282601983</integer>
    </dict>
    <key>WFWorkflowImportQuestions</key>
    <array/>
    <key>WFWorkflowMinimumClientVersion</key>
    <integer>900</integer>
    <key>WFWorkflowMinimumClientVersionString</key>
    <string>900</string>
    <key>WFWorkflowName</key>
    <string>Hello World</string>
    <key>WFWorkflowOutputContentItemClasses</key>
    <array/>
    <key>WFWorkflowTypes</key>
    <array/>
</dict>
</plist>
```
