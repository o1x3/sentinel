import Foundation
import Security

struct GeneratorService {

    struct Options {
        var length: Int = 20
        var includeUppercase: Bool = true
        var includeLowercase: Bool = true
        var includeNumbers: Bool = true
        var includeSymbols: Bool = true
        var excludeAmbiguous: Bool = false
    }

    private static let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private static let lowercase = "abcdefghijklmnopqrstuvwxyz"
    private static let numbers = "0123456789"
    private static let symbols = "!@#$%^&*()-_=+[]{}|;:,.<>?"

    private static let ambiguousChars: Set<Character> = ["O", "0", "l", "1", "I", "|"]

    /// Generate a cryptographically secure random password.
    static func generate(options: Options) -> String {
        var charset = ""
        if options.includeUppercase { charset += uppercase }
        if options.includeLowercase { charset += lowercase }
        if options.includeNumbers { charset += numbers }
        if options.includeSymbols { charset += symbols }

        guard !charset.isEmpty else { return "" }

        if options.excludeAmbiguous {
            charset = String(charset.filter { !ambiguousChars.contains($0) })
        }

        let chars = Array(charset)
        guard !chars.isEmpty else { return "" }

        var randomBytes = [UInt8](repeating: 0, count: options.length)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        guard status == errSecSuccess else { return "" }

        let password = String(randomBytes.map { byte in
            chars[Int(byte) % chars.count]
        })

        return password
    }
}
