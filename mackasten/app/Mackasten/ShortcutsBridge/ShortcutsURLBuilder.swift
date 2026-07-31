import Foundation

enum ShortcutsURLBuilder {
    static func run(name: String, text: String? = nil) -> URL? {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "name", value: name),
        ]
        if let text {
            items.append(URLQueryItem(name: "input", value: "text"))
            items.append(URLQueryItem(name: "text", value: text))
        }
        return make(hostPath: "run-shortcut", items: items)
    }

    static func open(name: String) -> URL? {
        make(hostPath: "open-shortcut", items: [URLQueryItem(name: "name", value: name)])
    }

    static func importShortcut(url: URL, name: String) -> URL? {
        make(
            hostPath: "import-shortcut",
            items: [
                URLQueryItem(name: "url", value: url.absoluteString),
                URLQueryItem(name: "name", value: name),
            ]
        )
    }

    private static func make(hostPath: String, items: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = hostPath
        components.queryItems = items
        return components.url
    }
}
