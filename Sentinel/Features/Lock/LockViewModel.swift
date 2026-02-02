import CryptoKit
import Foundation
import Observation

@Observable
final class LockViewModel {
    var password = ""
    var confirmPassword = ""
    var errorMessage: String?
    var isLoading = false

    private let keychain = KeychainService.shared

    // MARK: - First Launch Setup

    /// Create master password: derive key, store salt + verification data in keychain.
    func setup(appState: AppState) async {
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let salt = VaultCrypto.generateSalt()
            let key = VaultCrypto.deriveKey(password: password, salt: salt)
            let verification = try VaultCrypto.createVerificationData(using: key)

            try keychain.saveSalt(salt)
            try keychain.saveVerificationData(verification)

            appState.isFirstLaunch = false
            appState.unlock(with: key)
            clearFields()
        } catch {
            errorMessage = "Setup failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Unlock

    /// Verify master password against stored verification data.
    func unlock(appState: AppState) async {
        guard !password.isEmpty else {
            errorMessage = "Enter your master password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            guard let salt = try keychain.loadSalt(),
                  let verification = try keychain.loadVerificationData() else {
                errorMessage = "No master password configured"
                isLoading = false
                return
            }

            let key = VaultCrypto.deriveKey(password: password, salt: salt)

            if VaultCrypto.verifyKey(key, against: verification) {
                appState.unlock(with: key)
                clearFields()
            } else {
                errorMessage = "Incorrect password"
            }
        } catch {
            errorMessage = "Unlock failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Check if a master password has been set up.
    func checkFirstLaunch(appState: AppState) {
        do {
            let salt = try keychain.loadSalt()
            appState.isFirstLaunch = (salt == nil)
        } catch {
            appState.isFirstLaunch = true
        }
    }

    private func clearFields() {
        password = ""
        confirmPassword = ""
    }
}
