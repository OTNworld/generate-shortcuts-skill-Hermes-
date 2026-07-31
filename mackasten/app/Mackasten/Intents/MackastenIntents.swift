import AppIntents
import Foundation
import UIKit

struct MackastenPackageEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Mackasten Package")
    static var defaultQuery = MackastenPackageEntityQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(id)")
    }
}

struct MackastenPackageEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [MackastenPackageEntity] {
        let all = await MainActor.run { CatalogSnapshot.packages() }
        return all.filter { identifiers.contains($0.id) }.map {
            MackastenPackageEntity(id: $0.id, name: $0.name)
        }
    }

    func suggestedEntities() async throws -> [MackastenPackageEntity] {
        await MainActor.run {
            CatalogSnapshot.packages().map { MackastenPackageEntity(id: $0.id, name: $0.name) }
        }
    }
}

enum CatalogSnapshot {
    @MainActor
    static func packages() -> [MackastenPackage] {
        let store = PackageCatalogStore()
        store.reload()
        return store.packages
    }
}

struct InstallPackageIntent: AppIntent {
    static var title: LocalizedStringResource = "Install Mackasten Package"
    static var description = IntentDescription("Install a marketplace package into Shortcuts.")

    @Parameter(title: "Package")
    var package: MackastenPackageEntity

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "Open Mackasten and tap Install for \(package.name).")
    }
}

struct RunPackageIntent: AppIntent {
    static var title: LocalizedStringResource = "Run Mackasten Package"
    static var description = IntentDescription("Run an installed marketplace shortcut.")

    @Parameter(title: "Package")
    var package: MackastenPackageEntity

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let url = ShortcutsURLBuilder.run(name: package.name) {
            await UIApplication.shared.open(url)
        }
        return .result(dialog: "Running \(package.name)")
    }
}

struct BrowseCatalogIntent: AppIntent {
    static var title: LocalizedStringResource = "Browse Mackasten Catalog"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
