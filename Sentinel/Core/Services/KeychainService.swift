import Foundation
import Security
import LocalAuthentication

struct KeychainService {

    static let shared = KeychainService()

    private let accessGroup = "com.o1x3.Sentinel.shared"

    // MARK: - Generic Save/Load/Delete

    /// Save data to keychain. Overwrites if the key already exists.
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    /// Load data from keychain.
    func load(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.loadFailed(status)
        }
    }

    /// Delete a keychain item.
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - Biometric-Protected Storage

    /// Save data with biometric protection (requires biometric auth to read).
    func saveBiometricProtected(_ data: Data, forKey key: String) throws {
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        ) else {
            throw KeychainError.accessControlCreationFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessControl as String] = accessControl

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    /// Load biometric-protected data. Triggers biometric prompt.
    func loadBiometricProtected(forKey key: String, context: LAContext? = nil) throws -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: accessGroup,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        if let context {
            query[kSecUseAuthenticationContext as String] = context
        }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        case errSecAuthFailed, errSecUserCanceled:
            throw KeychainError.authenticationFailed
        default:
            throw KeychainError.loadFailed(status)
        }
    }

    // MARK: - Convenience: Salt

    private static let saltKey = "sentinel.master.salt"

    func saveSalt(_ salt: Data) throws {
        try save(salt, forKey: Self.saltKey)
    }

    func loadSalt() throws -> Data? {
        try load(forKey: Self.saltKey)
    }

    // MARK: - Convenience: Verification Data

    private static let verificationKey = "sentinel.master.verification"

    func saveVerificationData(_ data: Data) throws {
        try save(data, forKey: Self.verificationKey)
    }

    func loadVerificationData() throws -> Data? {
        try load(forKey: Self.verificationKey)
    }

    // MARK: - Convenience: Biometric Key

    private static let biometricKeyKey = "sentinel.biometric.key"

    func saveBiometricKey(_ keyData: Data) throws {
        try saveBiometricProtected(keyData, forKey: Self.biometricKeyKey)
    }

    func loadBiometricKey(context: LAContext? = nil) throws -> Data? {
        try loadBiometricProtected(forKey: Self.biometricKeyKey, context: context)
    }

    func deleteBiometricKey() throws {
        try delete(forKey: Self.biometricKeyKey)
    }
}

// MARK: - Errors

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case accessControlCreationFailed
    case authenticationFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status): "Keychain save failed (OSStatus \(status))"
        case .loadFailed(let status): "Keychain load failed (OSStatus \(status))"
        case .deleteFailed(let status): "Keychain delete failed (OSStatus \(status))"
        case .accessControlCreationFailed: "Failed to create access control"
        case .authenticationFailed: "Biometric authentication failed"
        }
    }
}
