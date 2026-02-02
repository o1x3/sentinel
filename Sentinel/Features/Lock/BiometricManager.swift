import Foundation
import LocalAuthentication

struct BiometricManager {

    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID
    }

    /// Check if biometric authentication is available.
    static func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Determine which biometric type is available.
    static func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .touchID: return .touchID
        case .faceID: return .faceID
        case .opticID: return .opticID
        default: return .none
        }
    }

    /// System icon name for the current biometric type.
    static var biometricIconName: String {
        switch biometricType() {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        case .none: "lock"
        }
    }

    /// Authenticate with biometrics. Returns true on success.
    static func authenticate(reason: String = "Unlock Sentinel") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            return false
        }
    }

    /// Authenticate and return an LAContext for keychain access.
    static func authenticateForKeychain(reason: String = "Unlock Sentinel") async -> LAContext? {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success ? context : nil
        } catch {
            return nil
        }
    }
}
