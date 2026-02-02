import Combine
import CryptoKit
import Foundation
import Observation

@Observable
final class TOTPViewModel {
    var codes: [UUID: String] = [:]
    var secondsRemaining: Int = 30
    var errorMessage: String?

    private var timer: AnyCancellable?

    func startTimer() {
        updateCodes()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func tick() {
        let now = Date()
        let newRemaining = TOTPService.secondsRemaining(date: now)

        // If we crossed a period boundary, regenerate all codes
        if newRemaining > secondsRemaining {
            updateCodes()
        }
        secondsRemaining = newRemaining
    }

    private func updateCodes() {
        // Codes are regenerated from the current accounts in the view
        // This method just triggers a refresh; actual generation happens in generateCode()
        secondsRemaining = TOTPService.secondsRemaining()
    }

    func generateCode(for account: TOTPAccount, using key: SymmetricKey) -> String {
        // Decrypt secret if needed
        if account.secret == nil {
            try? VaultService.decryptTOTPSecret(account, using: key)
        }

        guard let secret = account.secret else { return "------" }

        return TOTPService.generateCode(
            secret: secret,
            algorithm: account.algorithm,
            digits: account.digits,
            period: account.period
        ) ?? "------"
    }
}
