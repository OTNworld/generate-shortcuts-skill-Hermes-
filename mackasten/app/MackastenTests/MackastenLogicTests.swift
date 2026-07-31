import Foundation
import Testing
@testable import Mackasten

struct PackageDecodeTests {
    @Test func decodesSeedFixtures() throws {
        let fixtures = try Self.fixturePackages()
        #expect(fixtures.count >= 4)
        let ids = Set(fixtures.map(\.id))
        #expect(ids.contains("hello-world"))
        #expect(ids.contains("clipboard-set"))
        #expect(ids.contains("local-ask-llm"))
        #expect(ids.contains("local-rewrite"))
    }

    @Test func localPackagesNotCloudAllowed() throws {
        for pkg in try Self.fixturePackages() where pkg.id.hasPrefix("local-") {
            #expect(pkg.modelPolicy != .cloudAllowed)
            #expect(!pkg.violatesLocalCloudPolicy)
        }
    }

    private static func fixturePackages() throws -> [MackastenPackage] {
        let urls = fixtureManifestURLs()
        #expect(!urls.isEmpty)
        return try urls.map { try JSONDecoder().decode(MackastenPackage.self, from: Data(contentsOf: $0)) }
    }

    private static func fixtureManifestURLs() -> [URL] {
        let bundle = Bundle(for: BundleToken.self)
        let candidates: [URL?] = [
            bundle.resourceURL?.appendingPathComponent("Fixtures/packages", isDirectory: true),
            bundle.resourceURL?.appendingPathComponent("packages", isDirectory: true),
        ]
        let fm = FileManager.default
        for root in candidates.compactMap({ $0 }) where fm.fileExists(atPath: root.path) {
            let dirs = (try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? []
            let mans = dirs
                .map { $0.appendingPathComponent("package.json") }
                .filter { fm.fileExists(atPath: $0.path) }
            if !mans.isEmpty {
                return mans.sorted { $0.path < $1.path }
            }
        }
        return []
    }
}

struct DeepLinkTests {
    @Test func acceptsHelloWorldPath() {
        let url = URL(string: "hermes-shortcuts://edit?path=templates/examples/01-hello-world.shortcut.xml")!
        #expect(HermesShortcutsRouter.path(from: url) == "templates/examples/01-hello-world.shortcut.xml")
    }

    @Test func rejectsTraversal() {
        let url = URL(string: "hermes-shortcuts://edit?path=../../etc/passwd")!
        #expect(HermesShortcutsRouter.path(from: url) == nil)
    }

    @Test func rejectsMissingPath() {
        let url = URL(string: "hermes-shortcuts://edit")!
        #expect(HermesShortcutsRouter.path(from: url) == nil)
    }

    @Test func sanitizeRejectsAbsolute() {
        #expect(HermesShortcutsRouter.sanitize(path: "/tmp/x") == nil)
    }
}

struct URLBuilderTests {
    @Test func runEncodesSpaces() throws {
        let url = try #require(ShortcutsURLBuilder.run(name: "Hello World"))
        #expect(url.scheme == "shortcuts")
        #expect(url.host == "run-shortcut")
        #expect(url.absoluteString.contains("Hello%20World") || url.absoluteString.contains("Hello+World"))
    }
}

struct PolicyTests {
    @Test func localCloudAllowedViolates() throws {
        let json = """
        {"schema":"mackasten-package/v1","id":"local-x","name":"X","version":"1","license":"MIT","model_policy":"cloud-allowed","shortcuts":[{"path":"a","role":"primary"}]}
        """.data(using: .utf8)!
        let pkg = try JSONDecoder().decode(MackastenPackage.self, from: json)
        #expect(pkg.violatesLocalCloudPolicy)
        #expect(ModelRouter.allowsInstall(pkg) == false)
    }
}

private final class BundleToken {}
