import SwiftUI
import UIKit

struct CopyableField: View {
    let label: String
    let value: String
    var isSecret: Bool = false

    @State private var isRevealed = false
    @State private var showCopied = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isSecret && !isRevealed {
                    Text(String(repeating: "\u{2022}", count: 12))
                        .font(.body)
                } else {
                    Text(value)
                        .font(.body)
                        .textSelection(.enabled)
                }
            }

            Spacer()

            if isSecret {
                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Button {
                copyToClipboard()
            } label: {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    .foregroundStyle(showCopied ? Color.theme.success : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = value
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopied = false }
        }

        // Clear clipboard after 30 seconds
        let currentValue = value
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if UIPasteboard.general.string == currentValue {
                UIPasteboard.general.string = ""
            }
        }
    }
}
