import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

enum ExportImportMode {
    case export
    case import_
}

struct ExportImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var credentials: [Credential]
    @Query private var totpAccounts: [TOTPAccount]

    let mode: ExportImportMode
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isProcessing = false
    @State private var importFileURL: URL?
    @State private var showingFilePicker = false

    var body: some View {
        NavigationStack {
            Form {
                if mode == .export {
                    exportSection
                } else {
                    importSection
                }
            }
            .navigationTitle(mode == .export ? "Export Backup" : "Import Backup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var exportSection: some View {
        Group {
            Section("Encryption Password") {
                SecureFieldView(title: "Password", text: $password, isNewPassword: true)
                SecureFieldView(title: "Confirm Password", text: $confirmPassword, isNewPassword: true)
            }

            Section {
                Text("Your backup will be encrypted with this password. You'll need it to restore.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    exportBackup()
                } label: {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("Export \(credentials.count) credentials, \(totpAccounts.count) codes")
                    }
                }
                .disabled(password.isEmpty || password != confirmPassword || isProcessing)
            }

            if let error = errorMessage {
                Section { Text(error).foregroundStyle(Color.theme.danger) }
            }
            if let success = successMessage {
                Section { Text(success).foregroundStyle(Color.theme.success) }
            }
        }
    }

    private var importSection: some View {
        Group {
            Section {
                Button("Select Backup File") {
                    showingFilePicker = true
                }
                if let url = importFileURL {
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Decryption Password") {
                SecureFieldView(title: "Backup Password", text: $password)
            }

            Section {
                Button {
                    importBackup()
                } label: {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("Import")
                    }
                }
                .disabled(password.isEmpty || importFileURL == nil || isProcessing)
            }

            if let error = errorMessage {
                Section { Text(error).foregroundStyle(Color.theme.danger) }
            }
            if let success = successMessage {
                Section { Text(success).foregroundStyle(Color.theme.success) }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                importFileURL = url
            }
        }
    }

    private func exportBackup() {
        isProcessing = true
        errorMessage = nil

        do {
            let data = try ExportImportService.exportBackup(
                credentials: credentials,
                totpAccounts: totpAccounts,
                exportPassword: password
            )

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("sentinel-backup-\(Date().timeIntervalSince1970).sentinel")
            try data.write(to: tempURL)

            // Share the file
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }

            successMessage = "Backup created"
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
        }

        isProcessing = false
    }

    private func importBackup() {
        guard let url = importFileURL else { return }
        isProcessing = true
        errorMessage = nil

        do {
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }

            let data = try Data(contentsOf: url)
            let counts = try ExportImportService.importBackup(
                data: data,
                exportPassword: password,
                context: modelContext
            )
            successMessage = "Imported \(counts.credentials) credentials and \(counts.totpAccounts) codes"
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
        }

        isProcessing = false
    }
}
