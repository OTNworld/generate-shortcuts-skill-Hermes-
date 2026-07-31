import SwiftUI

struct CatalogListView: View {
    @Bindable var store: PackageCatalogStore

    var body: some View {
        NavigationStack {
            Group {
                if let err = store.loadError, store.packages.isEmpty {
                    ContentUnavailableView(
                        "Catalog unavailable",
                        systemImage: "tray",
                        description: Text(err)
                    )
                } else {
                    List(store.packages) { pkg in
                        NavigationLink(value: pkg) {
                            CatalogRow(package: pkg)
                        }
                    }
                }
            }
            .navigationTitle("Mackasten")
            .navigationDestination(for: MackastenPackage.self) { pkg in
                PackageDetailView(package: pkg, vendorRoot: store.vendorRoot)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Reload", systemImage: "arrow.clockwise") {
                        store.reload()
                    }
                }
            }
        }
    }
}

private struct CatalogRow: View {
    let package: MackastenPackage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(package.name)
                .font(.headline)
            Text(package.description ?? package.id)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack(spacing: 8) {
                if let policy = package.modelPolicy {
                    Text(policy.rawValue)
                        .font(.caption2.monospaced())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary, in: Capsule())
                }
                if let status = package.attestation?.status {
                    Text(status.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
