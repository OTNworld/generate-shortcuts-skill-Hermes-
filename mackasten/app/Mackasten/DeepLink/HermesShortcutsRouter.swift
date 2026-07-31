import Foundation

enum HermesShortcutsRouter {
    static let scheme = "hermes-shortcuts"
    static let allowedPrefixes = ["templates/", "mackasten/", "horizon/"]

    /// Parse `hermes-shortcuts://edit?path=…`
    static func path(from url: URL) -> String? {
        guard url.scheme?.lowercased() == scheme else { return nil }

        let host = (url.host ?? "").lowercased()
        let pathPart = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let isEdit = host == "edit" || pathPart == "edit" || pathPart.hasPrefix("edit/")
        guard isEdit else { return nil }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let raw = components.queryItems?.first(where: { $0.name == "path" })?.value
        else { return nil }
        return sanitize(path: raw)
    }

    static func sanitize(path: String) -> String? {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        if trimmed.hasPrefix("/") { return nil }
        if trimmed.contains("\\") { return nil }
        if trimmed.split(separator: "/").contains("..") { return nil }
        guard allowedPrefixes.contains(where: { trimmed.hasPrefix($0) }) else { return nil }
        return trimmed
    }
}
