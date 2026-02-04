import CryptoKit
import SwiftData
import Testing
import Foundation
@testable import Sentinel

struct ExportImportTests {

    @Test func roundTripExportImport() throws {
        let key = SymmetricKey(size: .bits256)

        let totp = TOTPAccount(
            issuer: "GitHub", label: "user@github.com",
            color: "purple", isFavorite: true, position: 5
        )
        try VaultService.encryptTOTPSecret(totp, secret: "JBSWY3DPEHPK3PXP", using: key)

        let exportPassword = "backup-password"
        let exported = try ExportImportService.exportBackup(
            totpAccounts: [totp],
            exportPassword: exportPassword
        )

        #expect(exported.count > 32) // salt + encrypted data

        // Import into fresh context
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TOTPAccount.self, configurations: config)
        let context = ModelContext(container)

        let count = try ExportImportService.importBackup(
            data: exported,
            exportPassword: exportPassword,
            context: context
        )

        #expect(count == 1)

        // Verify imported data preserves position, color, favorite
        let descriptor = FetchDescriptor<TOTPAccount>()
        let imported = try context.fetch(descriptor)
        #expect(imported.count == 1)
        #expect(imported[0].issuer == "GitHub")
        #expect(imported[0].color == "purple")
        #expect(imported[0].isFavorite == true)
        #expect(imported[0].position == 5)
    }

    @Test func wrongPasswordFailsImport() throws {
        let key = SymmetricKey(size: .bits256)
        let totp = TOTPAccount(issuer: "Test", label: "test")
        try VaultService.encryptTOTPSecret(totp, secret: "JBSWY3DPEHPK3PXP", using: key)

        let exported = try ExportImportService.exportBackup(
            totpAccounts: [totp],
            exportPassword: "correct-password"
        )

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TOTPAccount.self, configurations: config)
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
