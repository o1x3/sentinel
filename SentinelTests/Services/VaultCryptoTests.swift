import Testing
import Foundation
import CryptoKit
@testable import Sentinel

struct VaultCryptoTests {

    @Test func encryptDecryptRoundTrip() throws {
        let key = SymmetricKey(size: .bits256)
        let plaintext = Data("Hello, Sentinel!".utf8)

        let encrypted = try VaultCrypto.encrypt(plaintext, using: key)
        let decrypted = try VaultCrypto.decrypt(encrypted, using: key)

        #expect(decrypted == plaintext)
        #expect(encrypted != plaintext)
    }

    @Test func encryptDecryptStringRoundTrip() throws {
        let key = SymmetricKey(size: .bits256)
        let original = "p@ssw0rd!Str0ng#123"

        let encrypted = try VaultCrypto.encryptString(original, using: key)
        let decrypted = try VaultCrypto.decryptString(encrypted, using: key)

        #expect(decrypted == original)
    }

    @Test func keyDerivationIsDeterministic() {
        let password = "master-password"
        let salt = Data(repeating: 0xAB, count: 32)

        let key1 = VaultCrypto.deriveKey(password: password, salt: salt, iterations: 1000)
        let key2 = VaultCrypto.deriveKey(password: password, salt: salt, iterations: 1000)

        // Keys from same password+salt should be identical
        key1.withUnsafeBytes { bytes1 in
            key2.withUnsafeBytes { bytes2 in
                #expect(Array(bytes1) == Array(bytes2))
            }
        }
    }

    @Test func differentPasswordsProduceDifferentKeys() {
        let salt = Data(repeating: 0xAB, count: 32)

        let key1 = VaultCrypto.deriveKey(password: "password1", salt: salt, iterations: 1000)
        let key2 = VaultCrypto.deriveKey(password: "password2", salt: salt, iterations: 1000)

        key1.withUnsafeBytes { bytes1 in
            key2.withUnsafeBytes { bytes2 in
                #expect(Array(bytes1) != Array(bytes2))
            }
        }
    }

    @Test func differentSaltsProduceDifferentKeys() {
        let password = "same-password"
        let salt1 = Data(repeating: 0xAA, count: 32)
        let salt2 = Data(repeating: 0xBB, count: 32)

        let key1 = VaultCrypto.deriveKey(password: password, salt: salt1, iterations: 1000)
        let key2 = VaultCrypto.deriveKey(password: password, salt: salt2, iterations: 1000)

        key1.withUnsafeBytes { bytes1 in
            key2.withUnsafeBytes { bytes2 in
                #expect(Array(bytes1) != Array(bytes2))
            }
        }
    }

    @Test func verificationDataWorks() throws {
        let key = SymmetricKey(size: .bits256)
        let verificationData = try VaultCrypto.createVerificationData(using: key)

        #expect(VaultCrypto.verifyKey(key, against: verificationData))
    }

    @Test func wrongKeyFailsVerification() throws {
        let correctKey = SymmetricKey(size: .bits256)
        let wrongKey = SymmetricKey(size: .bits256)
        let verificationData = try VaultCrypto.createVerificationData(using: correctKey)

        #expect(!VaultCrypto.verifyKey(wrongKey, against: verificationData))
    }

    @Test func decryptWithWrongKeyThrows() throws {
        let key1 = SymmetricKey(size: .bits256)
        let key2 = SymmetricKey(size: .bits256)
        let encrypted = try VaultCrypto.encrypt(Data("secret".utf8), using: key1)

        #expect(throws: (any Error).self) {
            try VaultCrypto.decrypt(encrypted, using: key2)
        }
    }

    @Test func generateSaltProducesUniqueValues() {
        let salt1 = VaultCrypto.generateSalt()
        let salt2 = VaultCrypto.generateSalt()

        #expect(salt1.count == 32)
        #expect(salt2.count == 32)
        #expect(salt1 != salt2)
    }

    @Test func emptyStringEncryption() throws {
        let key = SymmetricKey(size: .bits256)
        let encrypted = try VaultCrypto.encryptString("", using: key)
        let decrypted = try VaultCrypto.decryptString(encrypted, using: key)
        #expect(decrypted == "")
    }
}
