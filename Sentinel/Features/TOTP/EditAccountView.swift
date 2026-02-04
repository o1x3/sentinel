import SwiftUI

struct EditAccountView: View {
    @Environment(\.dismiss) private var dismiss
    let account: TOTPAccount

    @State private var issuer: String
    @State private var label: String
    @State private var selectedColor: String?

    private let colorOptions: [(name: String, color: Color)] = [
        ("blue", .blue), ("purple", .purple), ("orange", .orange), ("green", .green),
        ("pink", .pink), ("teal", .teal), ("indigo", .indigo), ("mint", .mint),
    ]

    init(account: TOTPAccount) {
        self.account = account
        _issuer = State(initialValue: account.issuer)
        _label = State(initialValue: account.label)
        _selectedColor = State(initialValue: account.color)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Issuer", text: $issuer)
                    TextField("Label", text: $label)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        // "Auto" option
                        Button {
                            selectedColor = nil
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Text("A")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                if selectedColor == nil {
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 2.5)
                                        .frame(width: 42, height: 42)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        ForEach(colorOptions, id: \.name) { option in
                            Button {
                                selectedColor = option.name
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 36, height: 36)
                                    if selectedColor == option.name {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 2.5)
                                            .frame(width: 42, height: 42)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    HStack {
                        Text("Preview")
                        Spacer()
                        ServiceIconView(
                            name: issuer.isEmpty ? label : issuer,
                            colorOverride: selectedColor
                        )
                    }
                }
            }
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        account.issuer = issuer
        account.label = label
        account.color = selectedColor
        account.updatedAt = Date()
        dismiss()
    }
}
