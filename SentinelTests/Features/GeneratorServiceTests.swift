import Testing
import Foundation
@testable import Sentinel

struct GeneratorServiceTests {

    @Test func respectsLength() {
        let options = GeneratorService.Options(length: 32)
        let password = GeneratorService.generate(options: options)
        #expect(password.count == 32)
    }

    @Test func shortLength() {
        let options = GeneratorService.Options(length: 8)
        let password = GeneratorService.generate(options: options)
        #expect(password.count == 8)
    }

    @Test func lowercaseOnly() {
        let options = GeneratorService.Options(
            length: 50,
            includeUppercase: false,
            includeLowercase: true,
            includeNumbers: false,
            includeSymbols: false
        )
        let password = GeneratorService.generate(options: options)
        #expect(password == password.lowercased())
    }

    @Test func numbersOnly() {
        let options = GeneratorService.Options(
            length: 50,
            includeUppercase: false,
            includeLowercase: false,
            includeNumbers: true,
            includeSymbols: false
        )
        let password = GeneratorService.generate(options: options)
        #expect(password.allSatisfy { $0.isNumber })
    }

    @Test func excludeAmbiguous() {
        let ambiguous: Set<Character> = ["O", "0", "l", "1", "I", "|"]
        let options = GeneratorService.Options(
            length: 200,
            excludeAmbiguous: true
        )
        let password = GeneratorService.generate(options: options)
        let hasAmbiguous = password.contains { ambiguous.contains($0) }
        #expect(!hasAmbiguous)
    }

    @Test func emptyCharsetReturnsEmpty() {
        let options = GeneratorService.Options(
            length: 10,
            includeUppercase: false,
            includeLowercase: false,
            includeNumbers: false,
            includeSymbols: false
        )
        let password = GeneratorService.generate(options: options)
        #expect(password.isEmpty)
    }

    @Test func strengthCalculation() {
        #expect(PasswordStrength.calculate(for: "") == .weak)
        #expect(PasswordStrength.calculate(for: "abc") == .weak)
        #expect(PasswordStrength.calculate(for: "abcdef12") == .fair)
        #expect(PasswordStrength.calculate(for: "Abcdef123") == .good)
        #expect(PasswordStrength.calculate(for: "Abcdef123!@#XYZ") == .strong)
    }

    @Test func uniquePasswords() {
        let options = GeneratorService.Options(length: 20)
        let p1 = GeneratorService.generate(options: options)
        let p2 = GeneratorService.generate(options: options)
        #expect(p1 != p2)
    }
}
