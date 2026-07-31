import SwiftUI
import SwiftData

struct PackageDetailView: View {
    let package: MackastenPackage
    let vendorRoot: URL?

    @Environment(\.modelContext) private var modelContext
    @State private var banner: String?
    @State private var busy = false

    private var blockReason: String? {
        ModelRouter.runBlockedReason(for: package)
    }

    var body: some View {
        List {
            Section {
                Text(package.description ?? "")
                LabeledContent("Version", value: package.version)
                LabeledContent("License", value: package.license)
                if let policy = package.modelPolicy {
                    LabeledContent("Model", value: policy.rawValue)
                }
                if let status = package.attestation?.status {
                    LabeledContent("Attestation", value: status.rawValue)
                }
            }

            if let phrases = package.siriPhrases, !phrases.isEmpty {
                Section("Siri phrases") {
                    ForEach(phrases, id: \.self) { Text($0) }
                }
            }

            if let reason = blockReason {
                Section {
                    Text(reason)
                        .foregroundStyle(.orange)
                }
            }

            if let banner {
                Section { Text(banner).foregroundStyle(.secondary) }
            }

            Section {
                Button("Install") { Task { await install() } }
                    .disabled(busy || package.violatesLocalCloudPolicy)
                Button("Run") { Task { await run() } }
                    .disabled(busy)
            }
        }
        .navigationTitle(package.name)
    }

    @MainActor
    private func install() async {
        busy = true
        defer { busy = false }
        guard let vendorRoot else {
            banner = "Vendor root missing — fetch packages first."
            return
        }
        do {
            try ShortcutInstaller.install(package, vendorRoot: vendorRoot)
            let row = InstalledPackage(
                packageId: package.id,
                name: package.name,
                runName: package.runName,
                version: package.version
            )
            modelContext.insert(row)
            try? modelContext.save()
            banner = "Share sheet opened — complete import in Shortcuts."
        } catch {
            banner = error.localizedDescription
        }
    }

    @MainActor
    private func run() async {
        busy = true
        defer { busy = false }
        do {
            try ShortcutRunner.run(package)
            banner = blockReason ?? "Opened Shortcuts to run \(package.runName)."
        } catch {
            banner = error.localizedDescription
        }
    }
}
