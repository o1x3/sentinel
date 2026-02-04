import CryptoKit
import Foundation

struct VaultService {

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
