import Testing
import Foundation
@testable import Sentinel

struct ModelTests {

    @Test func credentialDefaultValues() {
        let credential = Credential()
        #expect(credential.name == "")
        #expect(credential.urls.isEmpty)
        #expect(credential.username == "")
        #expect(credential.encryptedPassword == Data())
        #expect(credential.isFavorite == false)
        #expect(credential.position == 0)
        #expect(credential.tags.isEmpty)
        #expect(credential.customFields.isEmpty)
        #expect(credential.password == nil)
        #expect(credential.notes == nil)
    }

    @Test func credentialInitWithValues() {
        let credential = Credential(
            name: "GitHub",
            urls: ["https://github.com"],
            username: "user@example.com",
            isFavorite: true,
            position: 1
        )
        #expect(credential.name == "GitHub")
        #expect(credential.urls == ["https://github.com"])
        #expect(credential.username == "user@example.com")
        #expect(credential.isFavorite == true)
        #expect(credential.position == 1)
    }

    @Test func customFieldCodableRoundTrip() throws {
        let fields = [
            CustomField(label: "PIN", encryptedValue: Data([1, 2, 3]), type: .pin),
            CustomField(label: "Recovery", encryptedValue: Data([4, 5, 6]), type: .text),
        ]

        let encoded = try JSONEncoder().encode(fields)
        let decoded = try JSONDecoder().decode([CustomField].self, from: encoded)

        #expect(decoded.count == 2)
        #expect(decoded[0].label == "PIN")
        #expect(decoded[0].type == .pin)
        #expect(decoded[0].encryptedValue == Data([1, 2, 3]))
        #expect(decoded[1].label == "Recovery")
        #expect(decoded[1].type == .text)
    }

    @Test func credentialCustomFieldsAccessor() {
        let credential = Credential(name: "Test")
        let fields = [
            CustomField(label: "API Key", type: .password),
            CustomField(label: "Note", type: .text),
        ]
        credential.customFields = fields

        let retrieved = credential.customFields
        #expect(retrieved.count == 2)
        #expect(retrieved[0].label == "API Key")
        #expect(retrieved[1].label == "Note")
    }

    @Test func totpAccountDefaultValues() {
        let account = TOTPAccount()
        #expect(account.issuer == "")
        #expect(account.label == "")
        #expect(account.algorithm == .sha1)
        #expect(account.digits == 6)
        #expect(account.period == 30)
        #expect(account.isFavorite == false)
        #expect(account.secret == nil)
    }

    @Test func totpAccountInitWithValues() {
        let account = TOTPAccount(
            issuer: "GitHub",
            label: "user@github.com",
            algorithm: .sha256,
            digits: 8,
            period: 60
        )
        #expect(account.issuer == "GitHub")
        #expect(account.label == "user@github.com")
        #expect(account.algorithm == .sha256)
        #expect(account.digits == 8)
        #expect(account.period == 60)
    }

    @Test func totpAlgorithmRawValues() {
        #expect(TOTPAlgorithm.sha1.rawValue == "SHA1")
        #expect(TOTPAlgorithm.sha256.rawValue == "SHA256")
        #expect(TOTPAlgorithm.sha512.rawValue == "SHA512")
    }

    @Test func customFieldFieldType() {
        let text = CustomField.FieldType.text
        let password = CustomField.FieldType.password
        let pin = CustomField.FieldType.pin

        #expect(text.rawValue == "text")
        #expect(password.rawValue == "password")
        #expect(pin.rawValue == "pin")
    }
}
