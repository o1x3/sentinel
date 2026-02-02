import CryptoKit
import Foundation

struct TOTPService {

    /// Generate a TOTP code for the given parameters.
    static func generateCode(
        secret: String,
        algorithm: TOTPAlgorithm = .sha1,
        digits: Int = 6,
        period: Int = 30,
        date: Date = Date()
    ) -> String? {
        guard let secretData = base32Decode(secret) else { return nil }

        let counter = UInt64(date.timeIntervalSince1970) / UInt64(period)
        var counterBigEndian = counter.bigEndian
        let counterData = Data(bytes: &counterBigEndian, count: 8)

        let hmac: Data
        let key = SymmetricKey(data: secretData)

        switch algorithm {
        case .sha1:
            var h = HMAC<Insecure.SHA1>(key: key)
            h.update(data: counterData)
            hmac = Data(h.finalize())
        case .sha256:
            var h = HMAC<SHA256>(key: key)
            h.update(data: counterData)
            hmac = Data(h.finalize())
        case .sha512:
            var h = HMAC<SHA512>(key: key)
            h.update(data: counterData)
            hmac = Data(h.finalize())
        }

        let offset = Int(hmac[hmac.count - 1] & 0x0f)
        let truncated = hmac[offset..<offset + 4]

        var number = truncated.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        number &= 0x7FFF_FFFF
        number = number % UInt32(pow(10, Float(digits)))

        return String(format: "%0\(digits)d", number)
    }

    /// Seconds remaining in the current TOTP period.
    static func secondsRemaining(period: Int = 30, date: Date = Date()) -> Int {
        period - (Int(date.timeIntervalSince1970) % period)
    }

    /// Parse an otpauth:// URI into components.
    static func parseURI(_ uri: String) -> TOTPParsedURI? {
        guard let url = URLComponents(string: uri),
              url.scheme == "otpauth",
              url.host == "totp" else { return nil }

        let path = String(url.path.dropFirst()) // Remove leading /
        let params = Dictionary(
            uniqueKeysWithValues: url.queryItems?.map { ($0.name, $0.value ?? "") } ?? []
        )

        guard let secret = params["secret"], !secret.isEmpty else { return nil }

        let parts = path.split(separator: ":", maxSplits: 1)
        let issuerFromPath = parts.count > 1 ? String(parts[0]) : ""
        let label = parts.count > 1 ? String(parts[1]) : path

        let issuer = params["issuer"] ?? issuerFromPath
        let algorithm = TOTPAlgorithm(rawValue: params["algorithm"] ?? "SHA1") ?? .sha1
        let digits = Int(params["digits"] ?? "6") ?? 6
        let period = Int(params["period"] ?? "30") ?? 30

        return TOTPParsedURI(
            issuer: issuer,
            label: label,
            secret: secret,
            algorithm: algorithm,
            digits: digits,
            period: period
        )
    }

    // MARK: - Base32

    static func base32Decode(_ string: String) -> Data? {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let input = string.uppercased().filter { alphabet.contains($0) }
        guard !input.isEmpty else { return nil }

        var bits = ""
        for char in input {
            guard let index = alphabet.firstIndex(of: char) else { return nil }
            let value = alphabet.distance(from: alphabet.startIndex, to: index)
            bits += String(value, radix: 2).leftPad(to: 5, with: "0")
        }

        var bytes = [UInt8]()
        for i in stride(from: 0, to: bits.count - 7, by: 8) {
            let start = bits.index(bits.startIndex, offsetBy: i)
            let end = bits.index(start, offsetBy: 8)
            if let byte = UInt8(String(bits[start..<end]), radix: 2) {
                bytes.append(byte)
            }
        }

        return bytes.isEmpty ? nil : Data(bytes)
    }
}

struct TOTPParsedURI {
    let issuer: String
    let label: String
    let secret: String
    let algorithm: TOTPAlgorithm
    let digits: Int
    let period: Int
}
