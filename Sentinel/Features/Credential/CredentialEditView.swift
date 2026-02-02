import SwiftData
import SwiftUI

enum CredentialEditMode {
    case create
    case edit(Credential)
}

struct CredentialEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    let mode: CredentialEditMode

    @State private var viewModel = CredentialViewModel()
    @State private var showingGenerator = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $viewModel.name)
                    TextField("Username", text: $viewModel.username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Password") {
                    SecureFieldView(
                        title: "Password",
                        text: $viewModel.password,
                        isNewPassword: !isEditing
                    )

                    Button("Generate Password") {
                        showingGenerator = true
                    }
                }

                Section("URLs") {
                    ForEach(viewModel.urls.indices, id: \.self) { index in
                        HStack {
                            TextField("URL", text: $viewModel.urls[index])
                                .textContentType(.URL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)

                            if viewModel.urls.count > 1 {
                                Button {
                                    viewModel.removeURL(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Button("Add URL") {
                        viewModel.addURL()
                    }
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 80)
                }

                Section("Custom Fields") {
                    ForEach(viewModel.customFields.indices, id: \.self) { index in
                        VStack(spacing: 8) {
                            HStack {
                                TextField("Label", text: Binding(
                                    get: { viewModel.customFields[index].label },
                                    set: { viewModel.customFields[index].label = $0 }
                                ))
                                .font(.caption)

                                Picker("Type", selection: Binding(
                                    get: { viewModel.customFields[index].type },
                                    set: { viewModel.customFields[index].type = $0 }
                                )) {
                                    Text("Text").tag(CustomField.FieldType.text)
                                    Text("Password").tag(CustomField.FieldType.password)
                                    Text("PIN").tag(CustomField.FieldType.pin)
                                }
                                .labelsHidden()

                                Button {
                                    viewModel.removeCustomField(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }

                            TextField("Value", text: Binding(
                                get: { viewModel.customFields[index].value },
                                set: { viewModel.customFields[index].value = $0 }
                            ))
                        }
                    }
                    Button("Add Field") {
                        viewModel.addCustomField()
                    }
                }

                Section {
                    Toggle("Favorite", isOn: $viewModel.isFavorite)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(Color.theme.danger)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Credential" : "New Credential")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .sheet(isPresented: $showingGenerator) {
                GeneratorView { password in
                    viewModel.password = password
                }
            }
            .onAppear { loadIfEditing() }
        }
    }

    private func loadIfEditing() {
        guard case .edit(let credential) = mode,
              let key = appState.cryptoKey else { return }
        viewModel.load(from: credential, using: key)
    }

    private func save() {
        guard let key = appState.cryptoKey else { return }

        let credential: Credential
        switch mode {
        case .create:
            credential = Credential()
            modelContext.insert(credential)
        case .edit(let existing):
            credential = existing
        }

        if viewModel.save(credential: credential, using: key, context: modelContext) {
            dismiss()
        }
    }
}
