import CryptoKit
import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var biometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometricEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometricEnabled") }
    }

    var autoLockTimeoutMinutes: Double {
        get {
            let seconds = UserDefaults.standard.double(forKey: "autoLockTimeout")
            return seconds > 0 ? seconds / 60 : 5
        }
        set {
            UserDefaults.standard.set(newValue * 60, forKey: "autoLockTimeout")
        }
    }

    var errorMessage: String?
    var successMessage: String?

    /// Enable biometrics: store the current encryption key in biometric-protected keychain.
    func enableBiometric(key: SymmetricKey) {
        do {
            let keyData = key.withUnsafeBytes { Data($0) }
            try KeychainService.shared.saveBiometricKey(keyData)
            biometricEnabled = true
            successMessage = "Biometric unlock enabled"
        } catch {
            errorMessage = "Failed to enable biometrics: \(error.localizedDescription)"
            biometricEnabled = false
        }
    }

    /// Disable biometrics: remove biometric key from keychain.
    func disableBiometric() {
        do {
            try KeychainService.shared.deleteBiometricKey()
            biometricEnabled = false
            successMessage = "Biometric unlock disabled"
        } catch {
            errorMessage = "Failed to disable biometrics: \(error.localizedDescription)"
        }
    }
}
