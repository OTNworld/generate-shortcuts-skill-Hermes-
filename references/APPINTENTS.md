# AppIntents Reference

Curated subset of **168** AppIntent identifiers commonly used with Shortcuts
(`appintentexecution`). Source of truth: [`data/appintents.json`](../data/appintents.json).
This is not a complete dump of every system AppIntent on macOS/iOS.

## AppIntents vs WF*Actions

| Aspect | WF*Actions | AppIntents |
|--------|-----------|------------|
| Identifier format | `is.workflow.actions.*` | PascalCase intent / deep-link ids |
| Origin | Legacy Shortcuts (pre-iOS 16) | App Intents framework (iOS 16+) |
| Invocation | Direct identifier in action | Via `appintentexecution` wrapper |
| Scope | Core shortcut actions | System integrations, deep links, app extensions |

## How to Invoke AppIntents

AppIntents are invoked using the `WFAppIntentExecutionAction` wrapper:

```xml
<dict>
    <key>WFWorkflowActionIdentifier</key>
    <string>is.workflow.actions.appintentexecution</string>
    <key>WFWorkflowActionParameters</key>
    <dict>
        <key>AppIntentDescriptor</key>
        <dict>
            <key>BundleIdentifier</key>
            <string>com.apple.AccessibilityUtilities.AXSettingsShortcuts</string>
            <key>Name</key>
            <string>Open VoiceOver</string>
            <key>TeamIdentifier</key>
            <string>0000000000</string>
            <key>AppIntentIdentifier</key>
            <string>OpenAccessibilityVoiceOverStaticDeepLinks</string>
        </dict>
    </dict>
</dict>
```

---

## Complete AppIntent Identifier List

All **168 curated** AppIntent identifiers in this skill (generated from SSOT):

### Open* (Settings / deep links) (66)
```
OpenAboutSettingsStaticDeepLinks,
OpenAccessibilityAudioDescriptionsStaticDeepLinks,
OpenAccessibilityAudioStaticDeepLinks, OpenAccessibilityCaptionsStaticDeepLinks,
OpenAccessibilityDisplayStaticDeepLinks,
OpenAccessibilityHearingDevicesStaticDeepLinks,
OpenAccessibilityHoverTextStaticDeepLinks,
OpenAccessibilityKeyboardStaticDeepLinks,
OpenAccessibilityLiveCaptionsStaticDeepLinks,
OpenAccessibilityLiveSpeechStaticDeepLinks,
OpenAccessibilityMotionStaticDeepLinks,
OpenAccessibilityPersonalVoiceStaticDeepLinks,
OpenAccessibilityPointerControlStaticDeepLinks,
OpenAccessibilityRTTStaticDeepLinks, OpenAccessibilityRootStaticDeepLinks,
OpenAccessibilityShortcutStaticDeepLinks, OpenAccessibilitySiriStaticDeepLinks,
OpenAccessibilitySpokenContentStaticDeepLinks,
OpenAccessibilitySwitchControlStaticDeepLinks,
OpenAccessibilityVocalShortcutsStaticDeepLinks,
OpenAccessibilityVoiceControlStaticDeepLinks,
OpenAccessibilityVoiceOverStaticDeepLinks, OpenAccessibilityZoomStaticDeepLinks,
OpenAirDropSettingsStaticDeepLinks, OpenAppStoreSettingsStaticDeepLinks,
OpenAppleIDSettingsStaticDeepLinks, OpenBatterySettingsStaticDeepLinks,
OpenBluetoothSettingsStaticDeepLinks, OpenCalendarScreenIntent, OpenCameraIntent,
OpenCameraSettingsStaticDeepLinks, OpenDeveloperSettingsStaticDeepLinks,
OpenDisplaySettingsStaticDeepLinks, OpenFamilySettingsStaticDeepLinks,
OpenFocusSettingsStaticDeepLinks, OpenGameCenterSettingsStaticDeepLinks,
OpenGeneralSettingsStaticDeepLinks, OpenHealthSettingsStaticDeepLinks,
OpenInternetAccountsSettingsStaticDeepLinks, OpenKeyboardSettingsStaticDeepLinks,
OpenLanguageSettingsStaticDeepLinks, OpenLockScreenSettingsStaticDeepLinks,
OpenMessagesSettingsStaticDeepLinks, OpenNetworkSettingsStaticDeepLinks,
OpenNotificationSettingsStaticDeepLinks, OpenPasswordsSettingsStaticDeepLinks,
OpenPhotosSettingsStaticDeepLinks, OpenPrivacySettingsStaticDeepLinks,
OpenReminderListIntent, OpenSafariSettingsStaticDeepLinks,
OpenScreenTimeSettingsStaticDeepLinks, OpenSecuritySettingsStaticDeepLinks,
OpenSiriSettingsStaticDeepLinks, OpenSmartReminderListIntent,
OpenSoftwareUpdateSettingsStaticDeepLinks, OpenSoundSettingsStaticDeepLinks,
OpenStorageSettingsStaticDeepLinks, OpenTabGroupIntent, OpenTabIntent,
OpenTrackpadSettingsStaticDeepLinks, OpenTranslateSettingsStaticDeepLinks,
OpenVPNSettingsStaticDeepLinks, OpenVoiceMemoFolderIntent,
OpenWalletSettingsStaticDeepLinks, OpenWallpaperSettingsStaticDeepLinks,
OpenWiFiSettingsStaticDeepLinks
```

### Create* (16)
```
CreateAlarmIntent, CreateAlbumIntent, CreateCalendarIntent, CreateEventIntent,
CreateMemoryIntent, CreateNoteFolderIntent, CreateNoteTagIntent,
CreatePrivateTabIntent, CreateReminderIntent, CreateReminderListIntent,
CreateTabGroupIntent, CreateTabIntent, CreateTimerIntent,
CreateVoiceMemoFolderIntent, CreateWorkflowIntent, CreateiCloudLinkIntent
```

### Toggle* (25)
```
ToggleAlarmIntent, ToggleAxAssistiveTouchIntent, ToggleAxAudioDescriptionsIntent,
ToggleAxClosedCaptioningIntent, ToggleAxColorFiltersIntent,
ToggleAxFullKeyboardAccessIntent, ToggleAxGuidedAccessIntent,
ToggleAxInvertColorsIntent, ToggleAxLiveListenIntent, ToggleAxReduceMotionIntent,
ToggleAxReduceTransparencyIntent, ToggleAxSpeakScreenIntent,
ToggleAxSwitchControlIntent, ToggleAxVoiceControlIntent, ToggleAxVoiceOverIntent,
ToggleAxZoomIntent, ToggleBluetoothIntent, ToggleCellularDataIntent,
ToggleDoNotDisturbIntent, ToggleFocusModeIntent, ToggleHomeAccessoryIntent,
ToggleLowPowerModeIntent, ToggleOrientationLockIntent, ToggleVPNIntent,
ToggleWiFiIntent
```

### Set* (16)
```
SetAirplaneModeIntent, SetAlwaysOnDisplayIntent, SetAppearanceIntent,
SetBrightnessIntent, SetCellularDataIntent, SetFlashlightIntent,
SetListeningModeIntent, SetLowPowerModeIntent, SetNightShiftIntent,
SetOrientationLockIntent, SetPersonalHotspotIntent, SetStageManagerIntent,
SetTrueToneIntent, SetVPNIntent, SetVolumeIntent, SetWiFiIntent
```

### Find* / Search* (18)
```
FindAlbumsIntent, FindBookmarksIntent, FindCalendarEventsIntent,
FindContactsIntent, FindFilesIntent, FindHomeDeviceIntent, FindHomeIntent,
FindHomeRoomIntent, FindHomeSceneIntent, FindNotesIntent, FindPhotosIntent,
FindReadingListItemsIntent, FindRemindersIntent, FindSportsEventsIntent,
FindTabGroupsIntent, FindTabsIntent, FindVoiceMemosIntent, SearchShortcutsIntent
```

### Delete* (8)
```
DeleteAlarmIntent, DeleteCalendarIntent, DeleteNoteFolderIntent,
DeleteNoteTagIntent, DeleteReminderListIntent, DeleteVoiceMemoFolderIntent,
DeleteVoiceMemosIntent, DeleteWorkflowIntent
```

### Other (19)
```
AddTagsToNotesIntent, CancelTimerIntent, ChangeReaderModeStateIntent,
CloseCalendarScreenIntent, CloseTabIntent, CompleteReminderIntent,
PauseTimerIntent, PinNotesIntent, PlayMusicIntent, PlayVoiceMemoIntent,
ProofreadIntent, RecognizeMusicIntent, RemoveTagsFromNotesIntent,
ResetStopwatchIntent, ResumeTimerIntent, RewriteIntent, RunShortcutIntent,
StartStopwatchIntent, SummarizeIntent
```

## Invocation Template

To invoke any AppIntent:

```xml
<dict>
    <key>WFWorkflowActionIdentifier</key>
    <string>is.workflow.actions.appintentexecution</string>
    <key>WFWorkflowActionParameters</key>
    <dict>
        <key>AppIntentDescriptor</key>
        <dict>
            <key>BundleIdentifier</key>
            <string>BUNDLE_ID</string>
            <key>Name</key>
            <string>DISPLAY_NAME</string>
            <key>AppIntentIdentifier</key>
            <string>APPINTENT_IDENTIFIER</string>
        </dict>
    </dict>
</dict>
```

Common Bundle Identifiers:
- `com.apple.AccessibilityUtilities.AXSettingsShortcuts` - Accessibility
- `com.apple.Preferences` - Settings
- `com.apple.clock` - Clock
- `com.apple.mobilenotes` - Notes
- `com.apple.reminders` - Reminders
- `com.apple.Safari` - Safari
- `com.apple.Home` - Home
- `com.apple.Photos` - Photos
