import SwiftUI

struct SettingsView: View {
    @Bindable var store: PackageCatalogStore

    var body: some View {
        NavigationStack {
            List {
                Section("Skill pin") {
                    LabeledContent("Ref", value: store.skillRef ?? "(unknown — fetch packages)")
                    Text("Release builds must pin SKILL_REF to a tag or SHA (see SkillPin.env.example).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Capabilities") {
                    LabeledContent(
                        "Apple Intelligence",
                        value: ModelRouter.appleIntelligenceAvailable() ? "available" : "unavailable"
                    )
                }
                Section("Deep link") {
                    Text("hermes-shortcuts://edit?path=templates/…")
                        .font(.footnote.monospaced())
                }
            }
            .navigationTitle("Settings")
        }
    }
}
