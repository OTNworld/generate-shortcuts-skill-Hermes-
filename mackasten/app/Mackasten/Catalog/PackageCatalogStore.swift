import Foundation

@Observable
@MainActor
final class PackageCatalogStore {
    private(set) var packages: [MackastenPackage] = []
    private(set) var skillRef: String?
    private(set) var loadError: String?
    private(set) var vendorRoot: URL?

    func reload() {
        loadError = nil
        packages = []
        skillRef = nil

        guard let root = Self.resolveVendorRoot() else {
            loadError = "Vendor/SkillPackages missing. Run ./scripts/fetch_skill_packages.sh then rebuild."
            return
        }
        vendorRoot = root

        let catalogURL = root.appendingPathComponent("catalog.json")
        if let data = try? Data(contentsOf: catalogURL),
           let catalog = try? JSONDecoder().decode(CatalogIndex.self, from: data) {
            skillRef = catalog.skillRef
        }

        var loaded: [MackastenPackage] = []
        let fm = FileManager.default
        guard let dirs = try? fm.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            loadError = "Cannot read Vendor/SkillPackages"
            return
        }
        for dir in dirs.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: dir.path, isDirectory: &isDir), isDir.boolValue else { continue }
            if dir.lastPathComponent == "schema" { continue }
            let man = dir.appendingPathComponent("package.json")
            guard let data = try? Data(contentsOf: man) else { continue }
            do {
                let pkg = try JSONDecoder().decode(MackastenPackage.self, from: data)
                if pkg.schema != "mackasten-package/v1" && pkg.schema != "horizon-package/v1" {
                    continue
                }
                loaded.append(pkg)
            } catch {
                loadError = "Decode failed for \(dir.lastPathComponent): \(error.localizedDescription)"
            }
        }
        packages = loaded
        if packages.isEmpty, loadError == nil {
            loadError = "No packages decoded under Vendor/SkillPackages"
        }
    }

    private struct CatalogIndex: Codable {
        var schema: String?
        var skillRef: String?
        var packages: [String]?
        enum CodingKeys: String, CodingKey {
            case schema, packages
            case skillRef = "skill_ref"
        }
    }

    static func resolveVendorRoot() -> URL? {
        if let bundled = Bundle.main.resourceURL?
            .appendingPathComponent("SkillPackages", isDirectory: true),
           FileManager.default.fileExists(atPath: bundled.path) {
            return bundled
        }
        // Dev: relative to process CWD when running tests / previews
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Vendor/SkillPackages", isDirectory: true)
        if FileManager.default.fileExists(atPath: cwd.path) {
            return cwd
        }
        return nil
    }
}
