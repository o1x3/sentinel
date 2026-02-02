import Foundation
import Observation

@Observable
final class GeneratorViewModel {
    var options = GeneratorService.Options()
    var generatedPassword = ""
    var strength: PasswordStrength = .weak

    /// Callback when user taps "Use Password".
    var onUsePassword: ((String) -> Void)?

    init() {
        regenerate()
    }

    func regenerate() {
        generatedPassword = GeneratorService.generate(options: options)
        strength = PasswordStrength.calculate(for: generatedPassword)
    }
}
