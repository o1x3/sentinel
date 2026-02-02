import CryptoKit
import Foundation
import Observation
import SwiftData

@Observable
final class CredentialViewModel {
    var name = ""
    var urls: [String] = [""]
    var username = ""
    var password = ""
    var notes = ""
    var category: String?
    var tags: [String] = []
    var isFavorite = false
    var customFields: [(id: UUID, label: String, value: String, type: CustomField.FieldType)] = []
    var errorMessage: String?

    /// Populate fields from an existing credential (decrypted).
    func load(from credential: Credential, using key: SymmetricKey) {
        name = credential.name
        urls = credential.urls.isEmpty ? [""] : credential.urls
        username = credential.username
        category = credential.category
        tags = credential.tags
        isFavorite = credential.isFavorite

        do {
            try VaultService.decryptCredential(credential, using: key)
            password = credential.password ?? ""
            notes = credential.notes ?? ""

            customFields = credential.customFields.map { field in
                let value = (try? VaultService.decryptCustomFieldValue(field, using: key)) ?? ""
                return (id: field.id, label: field.label, value: value, type: field.type)
            }
        } catch {
            errorMessage = "Failed to decrypt: \(error.localizedDescription)"
        }
    }

    /// Save (encrypt and persist) a credential.
    func save(credential: Credential, using key: SymmetricKey, context: ModelContext) -> Bool {
        guard !name.isEmpty else {
            errorMessage = "Name is required"
            return false
        }

        credential.name = name
        credential.urls = urls.filter { !$0.isEmpty }
        credential.username = username
        credential.category = category
        credential.tags = tags
        credential.isFavorite = isFavorite

        let passwordChanged = password != (credential.password ?? "")

        do {
            let fields = customFields.map { (label: $0.label, value: $0.value, type: $0.type) }
            try VaultService.encryptCredential(
                credential,
                password: password,
                notes: notes.isEmpty ? nil : notes,
                customFields: fields,
                using: key
            )

            if passwordChanged {
                credential.passwordUpdatedAt = Date()
            }

            return true
        } catch {
            errorMessage = "Failed to encrypt: \(error.localizedDescription)"
            return false
        }
    }

    func addURL() {
        urls.append("")
    }

    func removeURL(at index: Int) {
        guard urls.count > 1 else { return }
        urls.remove(at: index)
    }

    func addCustomField() {
        customFields.append((id: UUID(), label: "", value: "", type: .text))
    }

    func removeCustomField(at index: Int) {
        customFields.remove(at: index)
    }
}
