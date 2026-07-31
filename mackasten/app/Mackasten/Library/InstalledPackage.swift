import Foundation
import SwiftData

@Model
final class InstalledPackage {
    var packageId: String
    var name: String
    var runName: String
    var version: String
    var installedAt: Date
    var lastRunAt: Date?
    var isFavorite: Bool

    init(
        packageId: String,
        name: String,
        runName: String,
        version: String,
        installedAt: Date = .now,
        lastRunAt: Date? = nil,
        isFavorite: Bool = false
    ) {
        self.packageId = packageId
        self.name = name
        self.runName = runName
        self.version = version
        self.installedAt = installedAt
        self.lastRunAt = lastRunAt
        self.isFavorite = isFavorite
    }
}
