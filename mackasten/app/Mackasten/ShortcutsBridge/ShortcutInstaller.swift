import Foundation
import UIKit

@MainActor
enum ShortcutInstaller {
    /// Best-effort: stage XML and open Shortcuts import or share. User confirms in system UI.
    static func install(_ package: MackastenPackage, vendorRoot: URL) throws {
        guard ModelRouter.allowsInstall(package) else {
            throw InstallError.policyViolation
        }
        guard let primary = package.primaryShortcut else {
            throw InstallError.missingShortcut
        }
        let fileURL = vendorRoot
            .appendingPathComponent(package.id, isDirectory: true)
            .appendingPathComponent(primary.path, isDirectory: false)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw InstallError.fileMissing(fileURL.path)
        }
        // Prefer share sheet for local unsigned XML (import-shortcut needs a reachable URL).
        let activity = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.keyWindow?.rootViewController
                ?? scene.windows.first?.rootViewController
        else {
            throw InstallError.noPresenter
        }
        var presenter = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        presenter.present(activity, animated: true)
    }

    enum InstallError: Error, LocalizedError {
        case policyViolation
        case missingShortcut
        case fileMissing(String)
        case noPresenter

        var errorDescription: String? {
            switch self {
            case .policyViolation: "Package policy forbids install."
            case .missingShortcut: "No primary shortcut in package."
            case .fileMissing(let p): "Shortcut file missing: \(p)"
            case .noPresenter: "No view controller to present share sheet."
            }
        }
    }
}

@MainActor
enum ShortcutRunner {
    static func run(_ package: MackastenPackage) throws {
        if let reason = ModelRouter.runBlockedReason(for: package),
           package.modelPolicy != .none,
           package.modelPolicy != nil,
           !ModelRouter.appleIntelligenceAvailable(),
           package.modelPolicy == .appleIntelligence || package.modelPolicy == .onDevicePreferred {
            // Still allow run — shortcut may degrade; caller shows reason.
            _ = reason
        }
        guard let url = ShortcutsURLBuilder.run(name: package.runName) else {
            throw RunError.badURL
        }
        UIApplication.shared.open(url)
    }

    enum RunError: Error {
        case badURL
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first(where: \.isKeyWindow)
    }
}
