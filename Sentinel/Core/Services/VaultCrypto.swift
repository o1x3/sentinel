import CryptoKit
import Foundation
import CommonCrypto

struct VaultCrypto {

    // MARK: - Key Derivation (PBKDF2)

    /// Derive a 256-bit encryption key from a master password using PBKDF2-HMAC-SHA256.
    /// 600,000 iterations per OWASP recommendation for SHA256.
    static func deriveKey(password: String, salt: Data, iterations: Int = 600_000) -> SymmetricKey {
        let passwordData = Data(password.utf8)
        var derivedBytes = [UInt8](repeating: 0, count: 32)

        let status = passwordData.withUnsafeBytes { passwordPtr in
            salt.withUnsafeBytes { saltPtr in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passwordPtr.baseAddress?.assumingMemoryBound(to: Int8.self),
                    passwordData.count,
                    saltPtr.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(iterations),
                    &derivedBytes,
                    derivedBytes.count
                )
            }
        }

        guard status == kCCSuccess else {
            fatalError("PBKDF2 key derivation failed with status \(status)")
        }

        return SymmetricKey(data: Data(derivedBytes))
    }

    // MARK: - Salt Generation

    /// Generate a 32-byte cryptographically secure random salt.
    static func generateSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            fatalError("SecRandomCopyBytes failed with status \(status)")
        }
        return Data(bytes)
    }

    // MARK: - AES-GCM Encryption/Decryption

    /// Encrypt data using AES-GCM. Returns combined nonce + ciphertext + tag.
    static func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        return combined
    }

    /// Decrypt AES-GCM combined data (nonce + ciphertext + tag).
    static func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - String Convenience

    /// Encrypt a string, returning combined AES-GCM data.
    static func encryptString(_ string: String, using key: SymmetricKey) throws -> Data {
        try encrypt(Data(string.utf8), using: key)
    }

    /// Decrypt combined AES-GCM data to a string.
    static func decryptString(_ data: Data, using key: SymmetricKey) throws -> String {
        let decrypted = try decrypt(data, using: key)
        guard let string = String(data: decrypted, encoding: .utf8) else {
            throw CryptoError.decodingFailed
        }
        return string
    }

    // MARK: - Master Password Verification

    /// Create verification data that can later prove a key is correct without storing the key.
    /// Encrypts a known plaintext; if decryption succeeds later, the key is valid.
    static func createVerificationData(using key: SymmetricKey) throws -> Data {
        let knownPlaintext = Data("sentinel-verification-token".utf8)
        return try encrypt(knownPlaintext, using: key)
    }

    /// Verify that a key can decrypt the verification data.
    static func verifyKey(_ key: SymmetricKey, against verificationData: Data) -> Bool {
        guard let decrypted = try? decrypt(verificationData, using: key) else {
            return false
        }
        return decrypted == Data("sentinel-verification-token".utf8)
    }
}

// MARK: - Errors

enum CryptoError: LocalizedError {
    case encryptionFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .encryptionFailed: "Encryption failed"
        case .decodingFailed: "Failed to decode decrypted data as UTF-8"
        }
    }
}
