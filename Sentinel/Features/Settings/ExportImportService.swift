import CryptoKit
import Foundation
import SwiftData

struct ExportImportService {

    struct BackupData: Codable {
        let version: Int
        let exportedAt: Date
        let credentials: [CredentialBackup]?
        let totpAccounts: [TOTPAccountBackup]
    }

    /// Kept for backward-compatible decoding of old backup files.
    struct CredentialBackup: Codable {
        let id: UUID
        let name: String
        let urls: [String]
        let username: String
        let encryptedPassword: Data
        let encryptedNotes: Data?
        let customFieldsData: Data?
        let category: String?
        let tags: [String]
        let isFavorite: Bool
        let createdAt: Date
        let updatedAt: Date
    }

    struct TOTPAccountBackup: Codable {
        let id: UUID
        let issuer: String
        let label: String
        let encryptedSecret: Data
        let algorithm: String
        let digits: Int
        let period: Int
        let isFavorite: Bool
        let createdAt: Date
        let updatedAt: Date
    }

    /// Export TOTP data, then encrypt the JSON with a separate export password.
    static func exportBackup(
        totpAccounts: [TOTPAccount],
        exportPassword: String
    ) throws -> Data {
        let totpBackups = totpAccounts.map { t in
            TOTPAccountBackup(
                id: t.id, issuer: t.issuer, label: t.label,
                encryptedSecret: t.encryptedSecret, algorithm: t.algorithm.rawValue,
                digits: t.digits, period: t.period, isFavorite: t.isFavorite,
                createdAt: t.createdAt, updatedAt: t.updatedAt
            )
        }

        let backup = BackupData(
            version: 1,
            exportedAt: Date(),
            credentials: nil,
            totpAccounts: totpBackups
        )

        let json = try JSONEncoder().encode(backup)

        // Encrypt with export password
        let salt = VaultCrypto.generateSalt()
        let key = VaultCrypto.deriveKey(password: exportPassword, salt: salt, iterations: 100_000)
        let encrypted = try VaultCrypto.encrypt(json, using: key)

        // Prepend salt to encrypted data
        return salt + encrypted
    }

    /// Import a backup file, decrypting with the export password.
    static func importBackup(
        data: Data,
        exportPassword: String,
        context: ModelContext
    ) throws -> Int {
        guard data.count > 32 else {
            throw ExportImportError.invalidFile
        }

        let salt = data.prefix(32)
        let encrypted = data.dropFirst(32)

        let key = VaultCrypto.deriveKey(password: exportPassword, salt: Data(salt), iterations: 100_000)
        let json = try VaultCrypto.decrypt(Data(encrypted), using: key)
        let backup = try JSONDecoder().decode(BackupData.self, from: json)

        for tb in backup.totpAccounts {
            let account = TOTPAccount(
                id: tb.id, issuer: tb.issuer, label: tb.label,
                encryptedSecret: tb.encryptedSecret,
                algorithm: TOTPAlgorithm(rawValue: tb.algorithm) ?? .sha1,
                digits: tb.digits, period: tb.period,
                isFavorite: tb.isFavorite,
                createdAt: tb.createdAt, updatedAt: tb.updatedAt
            )
            context.insert(account)
        }

        return backup.totpAccounts.count
    }
}

enum ExportImportError: LocalizedError {
    case invalidFile
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .invalidFile: "Invalid backup file"
        case .decryptionFailed: "Wrong password or corrupted file"
        }
    }
}
