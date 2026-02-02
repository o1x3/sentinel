import Foundation

enum PasswordStrength: Int, CaseIterable {
    case weak = 0
    case fair = 1
    case good = 2
    case strong = 3

    var label: String {
        switch self {
        case .weak: "Weak"
        case .fair: "Fair"
        case .good: "Good"
        case .strong: "Strong"
        }
    }

    /// Calculate entropy-based strength.
    static func calculate(for password: String) -> PasswordStrength {
        guard !password.isEmpty else { return .weak }

        var charsetSize = 0
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { charsetSize += 26 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { charsetSize += 26 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { charsetSize += 10 }
        if password.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil { charsetSize += 32 }

        guard charsetSize > 0 else { return .weak }

        let entropy = Double(password.count) * log2(Double(charsetSize))

        switch entropy {
        case ..<28: return .weak
        case 28..<36: return .fair
        case 36..<60: return .good
        default: return .strong
        }
    }
}
