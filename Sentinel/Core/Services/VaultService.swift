import CryptoKit
import Foundation
import SwiftData

struct VaultService {

    // MARK: - Credential Encryption

    /// Encrypt sensitive fields on a credential before saving.
    static func encryptCredential(
        _ credential: Credential,
        password: String?,
        notes: String?,
        customFields: [(label: String, value: String, type: CustomField.FieldType)],
        using key: SymmetricKey
    ) throws {
        if let password, !password.isEmpty {
            credential.encryptedPassword = try VaultCrypto.encryptString(password, using: key)
        } else {
            credential.encryptedPassword = Data()
        }

        if let notes, !notes.isEmpty {
            credential.encryptedNotes = try VaultCrypto.encryptString(notes, using: key)
        } else {
            credential.encryptedNotes = nil
        }

        var encrypted: [CustomField] = []
        for field in customFields {
            let encValue = try VaultCrypto.encryptString(field.value, using: key)
            encrypted.append(CustomField(label: field.label, encryptedValue: encValue, type: field.type))
        }
        credential.customFields = encrypted
        credential.updatedAt = Date()
    }

    /// Decrypt sensitive fields on a credential for display.
    static func decryptCredential(_ credential: Credential, using key: SymmetricKey) throws {
        if !credential.encryptedPassword.isEmpty {
            credential.password = try VaultCrypto.decryptString(credential.encryptedPassword, using: key)
        } else {
            credential.password = ""
        }

        if let encNotes = credential.encryptedNotes {
            credential.notes = try VaultCrypto.decryptString(encNotes, using: key)
        } else {
            credential.notes = nil
        }
    }

    /// Decrypt a single custom field value.
    static func decryptCustomFieldValue(_ field: CustomField, using key: SymmetricKey) throws -> String {
        try VaultCrypto.decryptString(field.encryptedValue, using: key)
    }

    // MARK: - TOTP Account Encryption

    /// Encrypt the secret on a TOTP account.
    static func encryptTOTPSecret(_ account: TOTPAccount, secret: String, using key: SymmetricKey) throws {
        account.encryptedSecret = try VaultCrypto.encryptString(secret, using: key)
        account.updatedAt = Date()
    }

    /// Decrypt the secret on a TOTP account.
    static func decryptTOTPSecret(_ account: TOTPAccount, using key: SymmetricKey) throws {
        guard !account.encryptedSecret.isEmpty else {
            account.secret = ""
            return
        }
        account.secret = try VaultCrypto.decryptString(account.encryptedSecret, using: key)
    }
}
