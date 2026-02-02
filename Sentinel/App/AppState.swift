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

    var autoLockTimeout: TimeInterval {
        get { UserDefaults.standard.double(forKey: "autoLockTimeout").nonZeroOr(300) }
        set { UserDefaults.standard.set(newValue, forKey: "autoLockTimeout") }
    }

    private var backgroundDate: Date?

    func lock() {
        isUnlocked = false
        cryptoKey = nil
    }

    func unlock(with key: SymmetricKey) {
        cryptoKey = key
        isUnlocked = true
    }

    /// Called when app enters background.
    func didEnterBackground() {
        isObscured = true
        backgroundDate = Date()
    }

    /// Called when app returns to foreground. Locks if timeout exceeded.
    func willEnterForeground() {
        isObscured = false
        guard isUnlocked, let bg = backgroundDate else { return }
        if Date().timeIntervalSince(bg) >= autoLockTimeout {
            lock()
        }
        backgroundDate = nil
    }
}

private extension Double {
    func nonZeroOr(_ fallback: Double) -> Double {
        self == 0 ? fallback : self
    }
}
