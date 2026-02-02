import SwiftUI

struct SetupView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = LockViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.theme.accent)

                Text("Create Master Password")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("This password encrypts all your data. Choose something strong and memorable — it cannot be recovered.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    SecureFieldView(
                        title: "Master Password",
                        text: $viewModel.password,
                        isNewPassword: true
                    )
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureFieldView(
                        title: "Confirm Password",
                        text: $viewModel.confirmPassword,
                        isNewPassword: true
                    )
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.theme.danger)
                }

                Button {
                    Task { await viewModel.setup(appState: appState) }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Password")
                    }
                }
                .buttonStyle(.primary)
                .disabled(viewModel.isLoading || viewModel.password.isEmpty)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Welcome to Sentinel")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
