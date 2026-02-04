import Foundation

/// Represents a connected service account
struct Account: Identifiable, Codable, Equatable {
    let id: UUID
    let service: Service
    var name: String
    var isEnabled: Bool

    /// Reference key for Keychain storage
    var keychainKey: String {
        "deploystatus.token.\(id.uuidString)"
    }

    init(id: UUID = UUID(), service: Service, name: String, isEnabled: Bool = true) {
        self.id = id
        self.service = service
        self.name = name
        self.isEnabled = isEnabled
    }
}
