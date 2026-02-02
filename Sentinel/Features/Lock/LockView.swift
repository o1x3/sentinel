import SwiftUI

struct LockView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = LockViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "lock.shield")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.theme.accent)

                Text("Sentinel is Locked")
                    .font(.title2)
                    .fontWeight(.bold)

                SecureFieldView(
                    title: "Master Password",
                    text: $viewModel.password
                )
                .padding()
                .background(Color.theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .onSubmit {
                    Task { await viewModel.unlock(appState: appState) }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.theme.danger)
                }

                Button {
                    Task { await viewModel.unlock(appState: appState) }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Unlock")
                    }
                }
                .buttonStyle(.primary)
                .disabled(viewModel.isLoading || viewModel.password.isEmpty)
                .padding(.horizontal)

                // Biometric button — placeholder, enabled in Phase 6
                Button {
                    // TODO: Phase 6 — biometric unlock
                } label: {
                    Image(systemName: "faceid")
                        .font(.title2)
                        .foregroundStyle(Color.theme.accent)
                }
                .disabled(true)
                .opacity(0.3)

                Spacer()
            }
            .navigationTitle("Unlock")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
