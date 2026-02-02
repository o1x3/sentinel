import CryptoKit
import SwiftData
import Testing
import Foundation
@testable import Sentinel

struct ExportImportTests {

    @Test func roundTripExportImport() throws {
        // Create test data
        let key = SymmetricKey(size: .bits256)
        let credential = Credential(name: "GitHub", urls: ["https://github.com"], username: "user")
        try VaultService.encryptCredential(
            credential,
            password: "secret123",
            notes: "My notes",
            customFields: [],
            using: key
        )

        let totp = TOTPAccount(issuer: "GitHub", label: "user@github.com")
        try VaultService.encryptTOTPSecret(totp, secret: "JBSWY3DPEHPK3PXP", using: key)

        // Export
        let exportPassword = "backup-password"
        let exported = try ExportImportService.exportBackup(
            credentials: [credential],
            totpAccounts: [totp],
            exportPassword: exportPassword
        )

        #expect(exported.count > 32) // salt + encrypted data

        // Import into fresh context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Credential.self, TOTPAccount.self, configurations: config)
        let context = ModelContext(container)

        let counts = try ExportImportService.importBackup(
            data: exported,
            exportPassword: exportPassword,
            context: context
        )

        #expect(counts.credentials == 1)
        #expect(counts.totpAccounts == 1)
    }

    @Test func wrongPasswordFailsImport() throws {
        let key = SymmetricKey(size: .bits256)
        let credential = Credential(name: "Test")

        let exported = try ExportImportService.exportBackup(
            credentials: [credential],
            totpAccounts: [],
            exportPassword: "correct-password"
        )

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Credential.self, TOTPAccount.self, configurations: config)
        let context = ModelContext(container)

        #expect(throws: (any Error).self) {
            try ExportImportService.importBackup(
                data: exported,
                exportPassword: "wrong-password",
                context: context
            )
        }
    }
}
