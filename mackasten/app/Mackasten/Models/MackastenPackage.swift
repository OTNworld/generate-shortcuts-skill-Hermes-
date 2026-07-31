import Foundation

enum ModelPolicy: String, Codable, Sendable, CaseIterable {
    case none
    case appleIntelligence = "apple-intelligence"
    case onDevicePreferred = "on-device-preferred"
    case cloudAllowed = "cloud-allowed"
}

enum AttestationStatus: String, Codable, Sendable, CaseIterable {
    case unattested
    case macImport = "mac-import"
    case macRun = "mac-run"
    case iosSample = "ios-sample"
}

struct MackastenPackage: Codable, Identifiable, Hashable, Sendable {
    var schema: String
    var id: String
    var name: String
    var version: String
    var license: String
    var description: String?
    var tags: [String]?
    var modelPolicy: ModelPolicy?
    var siriPhrases: [String]?
    var shortcuts: [ShortcutRef]
    var attestation: Attestation?
    var edit: EditInfo?

    enum CodingKeys: String, CodingKey {
        case schema, id, name, version, license, description, tags, shortcuts, attestation, edit
        case modelPolicy = "model_policy"
        case siriPhrases = "siri_phrases"
    }

    struct ShortcutRef: Codable, Hashable, Sendable {
        var path: String
        var role: String
        var outputName: String?
        var skillPath: String?

        enum CodingKeys: String, CodingKey {
            case path, role
            case outputName = "output_name"
            case skillPath = "skill_path"
        }
    }

    struct Attestation: Codable, Hashable, Sendable {
        var matrixRef: String?
        var resultsRef: String?
        var status: AttestationStatus?

        enum CodingKeys: String, CodingKey {
            case status
            case matrixRef = "matrix_ref"
            case resultsRef = "results_ref"
        }
    }

    struct EditInfo: Codable, Hashable, Sendable {
        var skillPath: String?
        var deepLink: String?

        enum CodingKeys: String, CodingKey {
            case skillPath = "skill_path"
            case deepLink = "deep_link"
        }
    }

    var primaryShortcut: ShortcutRef? {
        shortcuts.first(where: { $0.role == "primary" }) ?? shortcuts.first
    }

    var runName: String {
        primaryShortcut?.outputName ?? name
    }

    /// H-C1: local-* packages must not use cloud-allowed.
    var violatesLocalCloudPolicy: Bool {
        id.hasPrefix("local-") && modelPolicy == .cloudAllowed
    }
}

enum ModelRouter {
    static func allowsInstall(_ package: MackastenPackage) -> Bool {
        !package.violatesLocalCloudPolicy
    }

    /// Simulator / unknown: treat AI as unavailable; real device can refine later.
    static func appleIntelligenceAvailable() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // Capability probe expands in Phase F; default optimistic on device until gated.
        return true
        #endif
    }

    static func runBlockedReason(for package: MackastenPackage) -> String? {
        if package.violatesLocalCloudPolicy {
            return "local-* packages cannot use cloud-allowed policy."
        }
        guard let policy = package.modelPolicy else { return nil }
        switch policy {
        case .none:
            return nil
        case .appleIntelligence, .onDevicePreferred:
            if !appleIntelligenceAvailable() {
                return "Apple Intelligence is unavailable on this device. You can still install the shortcut."
            }
            return nil
        case .cloudAllowed:
            return nil
        }
    }
}
