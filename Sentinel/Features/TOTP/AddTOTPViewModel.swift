import CryptoKit
import Foundation
import Observation

@Observable
final class AddTOTPViewModel {
    var issuer = ""
    var label = ""
    var secret = ""
    var algorithm: TOTPAlgorithm = .sha1
    var digits = 6
    var period = 30
    var errorMessage: String?
    var scannedURI: String?

    /// Parse a scanned QR code URI and populate fields.
    func parseScannedCode(_ code: String) -> Bool {
        guard let parsed = TOTPService.parseURI(code) else {
            errorMessage = "Invalid QR code. Expected an otpauth:// URI."
            return false
        }

        issuer = parsed.issuer
        label = parsed.label
        secret = parsed.secret
        algorithm = parsed.algorithm
        digits = parsed.digits
        period = parsed.period
        scannedURI = code
        errorMessage = nil
        return true
    }

    /// Validate and create a TOTPAccount.
    func createAccount(using key: SymmetricKey) -> TOTPAccount? {
        guard !secret.isEmpty else {
            errorMessage = "Secret is required"
            return nil
        }

        guard TOTPService.base32Decode(secret) != nil else {
            errorMessage = "Invalid Base32 secret"
            return nil
        }

        // Verify the secret generates a code
        guard TOTPService.generateCode(secret: secret, algorithm: algorithm, digits: digits, period: period) != nil else {
            errorMessage = "Could not generate code from this secret"
            return nil
        }

        let account = TOTPAccount(
            issuer: issuer,
            label: label,
            algorithm: algorithm,
            digits: digits,
            period: period
        )

        do {
            try VaultService.encryptTOTPSecret(account, secret: secret, using: key)
            return account
        } catch {
            errorMessage = "Encryption failed: \(error.localizedDescription)"
            return nil
        }
    }
}
