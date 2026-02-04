import SwiftData
import SwiftUI

struct AddTOTPView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @Query private var existingAccounts: [TOTPAccount]
    @State private var viewModel = AddTOTPViewModel()
    @State private var showingScanner = false
    @State private var activeTab = 0

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Method", selection: $activeTab) {
                    Text("Scan QR").tag(0)
                    Text("Manual Entry").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if activeTab == 0 {
                    scannerTab
                } else {
                    manualEntryTab
                }
            }
            .navigationTitle("Add 2FA Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(viewModel.secret.isEmpty)
                }
            }
        }
    }

    private var scannerTab: some View {
        VStack {
            QRScannerView { code in
                if viewModel.parseScannedCode(code) {
                    activeTab = 1 // Switch to manual to review/confirm
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.theme.danger)
                    .padding(.horizontal)
            }
        }
    }

    private var manualEntryTab: some View {
        Form {
            Section("Account") {
                TextField("Issuer (e.g. GitHub)", text: $viewModel.issuer)
                TextField("Label (e.g. user@example.com)", text: $viewModel.label)
            }

            Section("Secret") {
                TextField("Base32 Secret Key", text: $viewModel.secret)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.system(.body, design: .monospaced))
            }

            Section("Options") {
                Picker("Algorithm", selection: $viewModel.algorithm) {
                    ForEach(TOTPAlgorithm.allCases, id: \.self) { alg in
                        Text(alg.rawValue).tag(alg)
                    }
                }

                Picker("Digits", selection: $viewModel.digits) {
                    Text("6").tag(6)
                    Text("8").tag(8)
                }

                Picker("Period", selection: $viewModel.period) {
                    Text("30s").tag(30)
                    Text("60s").tag(60)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(Color.theme.danger)
                }
            }
        }
    }

    private func save() {
        guard let key = appState.cryptoKey,
              let account = viewModel.createAccount(using: key) else { return }
        account.position = (existingAccounts.map(\.position).max() ?? -1) + 1
        modelContext.insert(account)
        dismiss()
    }
}
