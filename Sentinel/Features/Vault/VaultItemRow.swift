import SwiftUI

struct VaultItemRow: View {
    let credential: Credential

    var body: some View {
        HStack(spacing: 12) {
            // Icon placeholder — replaced with ServiceIconView in Phase 7
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.theme.accent.opacity(0.15))
                    .frame(width: 40, height: 40)

                Text(credential.name.prefix(1).uppercased())
                    .font(.headline)
                    .foregroundStyle(Color.theme.accent)
            }

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
