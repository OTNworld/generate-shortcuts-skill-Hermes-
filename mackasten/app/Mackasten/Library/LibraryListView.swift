import SwiftUI
import SwiftData
import UIKit

struct LibraryListView: View {
    @Query(sort: \InstalledPackage.installedAt, order: .reverse) private var items: [InstalledPackage]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    ContentUnavailableView(
                        "No installed packages",
                        systemImage: "books.vertical",
                        description: Text("Install from the Catalog tab.")
                    )
                } else {
                    List {
                        ForEach(items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name).font(.headline)
                                    Text(item.packageId)
                                        .font(.caption.monospaced())
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("Run") {
                                    if let url = ShortcutsURLBuilder.run(name: item.runName) {
                                        item.lastRunAt = .now
                                        try? modelContext.save()
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .onDelete { indexSet in
                            for i in indexSet {
                                modelContext.delete(items[i])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Library")
        }
    }
}
