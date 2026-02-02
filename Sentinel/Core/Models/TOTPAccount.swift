import Foundation
import SwiftData

enum TOTPAlgorithm: String, Codable, CaseIterable {
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha512 = "SHA512"
}

@Model
final class TOTPAccount {
    var id: UUID
    var issuer: String
    var label: String
    var encryptedSecret: Data
    var algorithm: TOTPAlgorithm
    var digits: Int
    var period: Int
    var iconName: String?
    var color: String?
    var linkedCredentialId: UUID?
    var isFavorite: Bool
    var position: Int
    var createdAt: Date
    var updatedAt: Date

    @Transient var secret: String?

    init(
        id: UUID = UUID(),
        issuer: String = "",
        label: String = "",
        encryptedSecret: Data = Data(),
        algorithm: TOTPAlgorithm = .sha1,
        digits: Int = 6,
        period: Int = 30,
        iconName: String? = nil,
        color: String? = nil,
        linkedCredentialId: UUID? = nil,
        isFavorite: Bool = false,
        position: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.issuer = issuer
        self.label = label
        self.encryptedSecret = encryptedSecret
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
        self.iconName = iconName
        self.color = color
        self.linkedCredentialId = linkedCredentialId
        self.isFavorite = isFavorite
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
