import SwiftUI

struct RootTabView: View {
    @Binding var pendingEditPath: String?
    @State private var catalog = PackageCatalogStore()
    @State private var selectedTab: Tab = .catalog

    enum Tab: Hashable {
        case library, catalog, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryListView()
                .tabItem { Label("Library", systemImage: "books.vertical") }
                .tag(Tab.library)

            CatalogListView(store: catalog)
                .tabItem { Label("Catalog", systemImage: "square.grid.2x2") }
                .tag(Tab.catalog)

            SettingsView(store: catalog)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .task { catalog.reload() }
        .sheet(item: Binding(
            get: { pendingEditPath.map(EditPathSheet.init(path:)) },
            set: { pendingEditPath = $0?.path }
        )) { item in
            EditPathSheetView(path: item.path) {
                pendingEditPath = nil
            }
        }
    }
}

private struct EditPathSheet: Identifiable {
    let path: String
    var id: String { path }
}

private struct EditPathSheetView: View {
    let path: String
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit in skill")
                    .font(.title2.weight(.semibold))
                Text(path)
                    .font(.body.monospaced())
                    .textSelection(.enabled)
                Text("Open this path in the Hermes Shortcuts skill workspace (Cursor / local clone).")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDismiss)
                }
            }
        }
    }
}
