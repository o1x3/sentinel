import CryptoKit
import Testing
import Foundation
@testable import Sentinel

struct CredentialViewModelTests {

    @Test func saveEncryptsPassword() throws {
        let key = SymmetricKey(size: .bits256)
        let credential = Credential(name: "Test")
        let vm = CredentialViewModel()
        vm.name = "GitHub"
        vm.username = "user@test.com"
        vm.password = "s3cret!"
        vm.notes = "Some notes"

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Credential.self, TOTPAccount.self, configurations: config)
        let context = ModelContext(container)
        context.insert(credential)

        let success = vm.save(credential: credential, using: key, context: context)
        #expect(success)
        #expect(credential.name == "GitHub")
        #expect(!credential.encryptedPassword.isEmpty)
        // Encrypted data should not be the plaintext
        #expect(credential.encryptedPassword != Data("s3cret!".utf8))
    }

    @Test func decryptReturnsOriginalValues() throws {
        let key = SymmetricKey(size: .bits256)
        let credential = Credential(name: "Test")
        let vm = CredentialViewModel()
        vm.name = "Test"
        vm.password = "mypassword"
        vm.notes = "private notes"

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Credential.self, TOTPAccount.self, configurations: config)
        let context = ModelContext(container)
        context.insert(credential)

        _ = vm.save(credential: credential, using: key, context: context)

        // Reset VM and reload
        let vm2 = CredentialViewModel()
        vm2.load(from: credential, using: key)

        #expect(vm2.password == "mypassword")
        #expect(vm2.notes == "private notes")
    }

    @Test func customFieldsRoundTrip() throws {
        let key = SymmetricKey(size: .bits256)
        let credential = Credential(name: "Test")
        let vm = CredentialViewModel()
        vm.name = "Test"
        vm.password = ""
        vm.customFields = [
            (id: UUID(), label: "API Key", value: "abc123", type: .password),
            (id: UUID(), label: "Note", value: "some text", type: .text),
        ]

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Credential.self, TOTPAccount.self, configurations: config)
        let context = ModelContext(container)
        context.insert(credential)

        _ = vm.save(credential: credential, using: key, context: context)

        let vm2 = CredentialViewModel()
        vm2.load(from: credential, using: key)

        #expect(vm2.customFields.count == 2)
        #expect(vm2.customFields[0].label == "API Key")
        #expect(vm2.customFields[0].value == "abc123")
        #expect(vm2.customFields[1].label == "Note")
        #expect(vm2.customFields[1].value == "some text")
    }
}
