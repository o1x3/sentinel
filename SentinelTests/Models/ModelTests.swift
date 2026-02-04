import Testing
import Foundation
@testable import Sentinel

struct ModelTests {

    @Test func totpAccountDefaultValues() {
        let account = TOTPAccount()
        #expect(account.issuer == "")
        #expect(account.label == "")
        #expect(account.algorithm == .sha1)
        #expect(account.digits == 6)
        #expect(account.period == 30)
        #expect(account.isFavorite == false)
        #expect(account.position == 0)
        #expect(account.color == nil)
        #expect(account.secret == nil)
    }

    @Test func totpAccountInitWithValues() {
        let account = TOTPAccount(
            issuer: "GitHub",
            label: "user@github.com",
            algorithm: .sha256,
            digits: 8,
            period: 60,
            color: "blue",
            isFavorite: true,
            position: 3
        )
        #expect(account.issuer == "GitHub")
        #expect(account.label == "user@github.com")
        #expect(account.algorithm == .sha256)
        #expect(account.digits == 8)
        #expect(account.period == 60)
        #expect(account.color == "blue")
        #expect(account.isFavorite == true)
        #expect(account.position == 3)
    }

    @Test func totpAlgorithmRawValues() {
        #expect(TOTPAlgorithm.sha1.rawValue == "SHA1")
        #expect(TOTPAlgorithm.sha256.rawValue == "SHA256")
        #expect(TOTPAlgorithm.sha512.rawValue == "SHA512")
    }
}
