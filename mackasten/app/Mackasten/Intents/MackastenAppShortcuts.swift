import AppIntents

struct MackastenAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: BrowseCatalogIntent(),
                phrases: [
                    "Open \(.applicationName) catalog",
                    "Browse \(.applicationName) packages",
                ],
                shortTitle: "Browse catalog",
                systemImageName: "square.grid.2x2"
            ),
            AppShortcut(
                intent: InstallPackageIntent(),
                phrases: [
                    "Install a package in \(.applicationName)",
                ],
                shortTitle: "Install package",
                systemImageName: "square.and.arrow.down"
            ),
            AppShortcut(
                intent: RunPackageIntent(),
                phrases: [
                    "Run a package in \(.applicationName)",
                    "Run Hello World in \(.applicationName)",
                ],
                shortTitle: "Run package",
                systemImageName: "play.fill"
            ),
        ]
    }
}
