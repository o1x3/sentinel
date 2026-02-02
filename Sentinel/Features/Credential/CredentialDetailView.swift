import SwiftData
import SwiftUI

struct CredentialDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    let credential: Credential

    @State private var isDecrypted = false
    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        List {
            if !credential.urls.isEmpty {
                Section("URLs") {
                    ForEach(credential.urls, id: \.self) { url in
                        CopyableField(label: "URL", value: url)
                    }
                }
            }

            Section("Credentials") {
                if !credential.username.isEmpty {
                    CopyableField(label: "Username", value: credential.username)
                }

                if isDecrypted, let password = credential.password, !password.isEmpty {
                    CopyableField(label: "Password", value: password, isSecret: true)
                } else if !credential.encryptedPassword.isEmpty {
                    Button("Reveal Password") {
                        decrypt()
                    }
                }
            }

            if isDecrypted, let notes = credential.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .font(.body)
                        .textSelection(.enabled)
                }
            }

            if isDecrypted {
                let fields = credential.customFields
                if !fields.isEmpty {
                    Section("Custom Fields") {
                        ForEach(fields) { field in
                            if let key = appState.cryptoKey,
                               let value = try? VaultService.decryptCustomFieldValue(field, using: key) {
                                CopyableField(
                                    label: field.label,
                                    value: value,
                                    isSecret: field.type == .password || field.type == .pin
                                )
                            }
                        }
                    }
                }
            }

            Section {
                HStack {
                    Text("Created")
                    Spacer()
                    Text(credential.createdAt, style: .date)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Updated")
                    Spacer()
                    Text(credential.updatedAt, style: .date)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("Delete Credential", systemImage: "trash")
                }
            }
        }
        .navigationTitle(credential.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            CredentialEditView(mode: .edit(credential))
        }
        .confirmationDialog("Delete Credential?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(credential)
            }
        } message: {
            Text("This cannot be undone.")
        }
        .onAppear { decrypt() }
    }

    private func decrypt() {
        guard let key = appState.cryptoKey else { return }
        do {
            try VaultService.decryptCredential(credential, using: key)
            isDecrypted = true
        } catch {
            // Decryption failed — keep fields hidden
        }
    }
}
