import SwiftUI

struct VaultItemRow: View {
    let credential: Credential

    var body: some View {
        HStack(spacing: 12) {
            ServiceIconView(name: credential.name)

            VStack(alignment: .leading, spacing: 2) {
                Text(credential.name)
                    .font(.headline)
                    .lineLimit(1)

                if !credential.username.isEmpty {
                    Text(credential.username)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if credential.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }

            if credential.linkedTOTPId != nil {
                Image(systemName: "clock.badge.checkmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
