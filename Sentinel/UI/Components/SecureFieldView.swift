import SwiftUI

struct SecureFieldView: View {
    let title: String
    @Binding var text: String
    var isNewPassword: Bool = false

    @State private var isRevealed = false

    var body: some View {
        HStack {
            Group {
                if isRevealed {
                    TextField(title, text: $text)
                        .textContentType(isNewPassword ? .newPassword : .password)
                } else {
                    SecureField(title, text: $text)
                        .textContentType(isNewPassword ? .newPassword : .password)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}
