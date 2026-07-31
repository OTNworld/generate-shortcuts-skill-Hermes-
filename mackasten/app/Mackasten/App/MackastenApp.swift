import SwiftUI
import SwiftData

@main
struct MackastenApp: App {
    @State private var deepLinkPath: String?

    var body: some Scene {
        WindowGroup {
            RootTabView(pendingEditPath: $deepLinkPath)
                .onOpenURL { url in
                    if let path = HermesShortcutsRouter.path(from: url) {
                        deepLinkPath = path
                    }
                }
        }
        .modelContainer(for: InstalledPackage.self)
    }
}
