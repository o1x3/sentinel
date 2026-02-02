import Foundation
import SwiftData

@Model
final class Credential {
    var id: UUID
    var name: String
    var urls: [String]
    var username: String
    var encryptedPassword: Data
    var encryptedNotes: Data?
    var customFieldsData: Data?
    var linkedTOTPId: UUID?
    var category: String?
    var tags: [String]
    var isFavorite: Bool
    var position: Int
    var createdAt: Date
    var updatedAt: Date
    var passwordUpdatedAt: Date

    @Transient var password: String?
    @Transient var notes: String?

    var customFields: [CustomField] {
        get {
            guard let data = customFieldsData else { return [] }
            return (try? JSONDecoder().decode([CustomField].self, from: data)) ?? []
        }
        set {
            customFieldsData = try? JSONEncoder().encode(newValue)
        }
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        urls: [String] = [],
        username: String = "",
        encryptedPassword: Data = Data(),
        encryptedNotes: Data? = nil,
        customFields: [CustomField] = [],
        linkedTOTPId: UUID? = nil,
        category: String? = nil,
        tags: [String] = [],
        isFavorite: Bool = false,
        position: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        passwordUpdatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.urls = urls
        self.username = username
        self.encryptedPassword = encryptedPassword
        self.encryptedNotes = encryptedNotes
        self.linkedTOTPId = linkedTOTPId
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.passwordUpdatedAt = passwordUpdatedAt
        self.customFieldsData = try? JSONEncoder().encode(customFields)
    }
}
