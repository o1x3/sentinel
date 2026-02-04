import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SettingsViewModel()
    @State private var showingExport = false
    @State private var showingImport = false

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $viewModel.appearanceMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Security") {
                if BiometricManager.canUseBiometrics() {
                    Toggle(biometricLabel, isOn: Binding(
                        get: { viewModel.biometricEnabled },
                        set: { enabled in
                            if enabled, let key = appState.cryptoKey {
                                viewModel.enableBiometric(key: key)
                            } else {
                                viewModel.disableBiometric()
                            }
                        }
                    ))
                }

                HStack {
                    Text("Auto-Lock")
                    Spacer()
                    Picker("", selection: $viewModel.autoLockTimeoutMinutes) {
                        Text("1 min").tag(1.0)
                        Text("5 min").tag(5.0)
                        Text("15 min").tag(15.0)
                        Text("30 min").tag(30.0)
                    }
                    .pickerStyle(.menu)
                }

                HStack {
                    Text("Clear Clipboard")
                    Spacer()
                    Picker("", selection: $viewModel.clipboardClearSeconds) {
                        Text("15 seconds").tag(15)
                        Text("30 seconds").tag(30)
                        Text("60 seconds").tag(60)
                        Text("Never").tag(0)
                    }
                    .pickerStyle(.menu)
                }
            }

            Section("Data") {
                Button {
                    showingExport = true
                } label: {
                    Label("Export Encrypted Backup", systemImage: "square.and.arrow.up")
                }

                Button {
                    showingImport = true
                } label: {
                    Label("Import Backup", systemImage: "square.and.arrow.down")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    appState.lock()
                } label: {
                    Label("Lock Now", systemImage: "lock.fill")
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundStyle(Color.theme.danger)
                }
            }
            if let success = viewModel.successMessage {
                Section {
                    Text(success).foregroundStyle(Color.theme.success)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingExport) {
            ExportImportView(mode: .export)
        }
        .sheet(isPresented: $showingImport) {
            ExportImportView(mode: .import_)
        }
    }

    private var biometricLabel: String {
        switch BiometricManager.biometricType() {
        case .faceID: "Unlock with Face ID"
        case .touchID: "Unlock with Touch ID"
        case .opticID: "Unlock with Optic ID"
        case .none: "Biometric Unlock"
        }
    }
}
