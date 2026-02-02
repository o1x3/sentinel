import CryptoKit
import Foundation
import Observation

@Observable
final class AppState {
    var isUnlocked = false
    var isFirstLaunch = true
    var isObscured = false

    /// The active encryption key — nil means locked.
    /// Lives in memory only; never persisted to disk unprotected.
    var cryptoKey: SymmetricKey?

    var autoLockTimeout: TimeInterval = 300 // 5 minutes default

    func lock() {
        isUnlocked = false
        cryptoKey = nil
    }

    func unlock(with key: SymmetricKey) {
        cryptoKey = key
        isUnlocked = true
    }
}
