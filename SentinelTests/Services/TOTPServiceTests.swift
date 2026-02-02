import Testing
import Foundation
@testable import Sentinel

struct TOTPServiceTests {

    // Known test vector: JBSWY3DPEHPK3PXP with SHA1, 6 digits, 30s period
    // at time 1234567890 (2009-02-13T23:31:30Z) => code 005924

    @Test func knownTestVector() {
        let date = Date(timeIntervalSince1970: 1234567890)
        let code = TOTPService.generateCode(
            secret: "JBSWY3DPEHPK3PXP",
            algorithm: .sha1,
            digits: 6,
            period: 30,
            date: date
        )
        #expect(code == "005924")
    }

    @Test func base32Decode() {
        let data = TOTPService.base32Decode("JBSWY3DPEHPK3PXP")
        #expect(data != nil)
        // "JBSWY3DPEHPK3PXP" decodes to "Hello!\xDE\xAD\xBE\xEF" — 10 bytes
        #expect(data?.count == 10)
    }

    @Test func base32DecodeInvalidReturnsNil() {
        let data = TOTPService.base32Decode("")
        #expect(data == nil)
    }

    @Test func uriParsing() {
        let uri = "otpauth://totp/GitHub:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub&algorithm=SHA1&digits=6&period=30"
        let parsed = TOTPService.parseURI(uri)

        #expect(parsed != nil)
        #expect(parsed?.issuer == "GitHub")
        #expect(parsed?.label == "user@example.com")
        #expect(parsed?.secret == "JBSWY3DPEHPK3PXP")
        #expect(parsed?.algorithm == .sha1)
        #expect(parsed?.digits == 6)
        #expect(parsed?.period == 30)
    }

    @Test func uriParsingDefaults() {
        let uri = "otpauth://totp/Demo:test?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ"
        let parsed = TOTPService.parseURI(uri)

        #expect(parsed != nil)
        #expect(parsed?.algorithm == .sha1)
        #expect(parsed?.digits == 6)
        #expect(parsed?.period == 30)
    }

    @Test func uriParsingInvalid() {
        #expect(TOTPService.parseURI("https://example.com") == nil)
        #expect(TOTPService.parseURI("otpauth://hotp/Test?secret=ABC") == nil)
        #expect(TOTPService.parseURI("otpauth://totp/Test") == nil) // no secret
    }

    @Test func secondsRemaining() {
        // At exactly a period boundary
        let date = Date(timeIntervalSince1970: 90) // 90 / 30 = 3, remainder 0
        let remaining = TOTPService.secondsRemaining(period: 30, date: date)
        #expect(remaining == 30)

        // Mid-period
        let date2 = Date(timeIntervalSince1970: 95) // 95 % 30 = 5, remaining = 25
        let remaining2 = TOTPService.secondsRemaining(period: 30, date: date2)
        #expect(remaining2 == 25)
    }

    @Test func codeGenerationWith8Digits() {
        let date = Date(timeIntervalSince1970: 1234567890)
        let code = TOTPService.generateCode(
            secret: "JBSWY3DPEHPK3PXP",
            algorithm: .sha1,
            digits: 8,
            period: 30,
            date: date
        )
        #expect(code != nil)
        #expect(code?.count == 8)
    }

    @Test func sha256Algorithm() {
        let code = TOTPService.generateCode(
            secret: "JBSWY3DPEHPK3PXP",
            algorithm: .sha256,
            date: Date(timeIntervalSince1970: 1234567890)
        )
        #expect(code != nil)
        #expect(code?.count == 6)
    }
}
