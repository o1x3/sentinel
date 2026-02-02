import CryptoKit
import SwiftUI

struct LockView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = LockViewModel()
    @State private var biometricsAvailable = false

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

                if biometricsAvailable {
                    Button {
                        Task { await biometricUnlock() }
                    } label: {
                        Image(systemName: BiometricManager.biometricIconName)
                            .font(.title2)
                            .foregroundStyle(Color.theme.accent)
                    }
                }

                Spacer()
            }
            .navigationTitle("Unlock")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                biometricsAvailable = BiometricManager.canUseBiometrics()
                    && UserDefaults.standard.bool(forKey: "biometricEnabled")
                if biometricsAvailable {
                    Task { await biometricUnlock() }
                }
            }
        }
    }

    private func biometricUnlock() async {
        guard let context = await BiometricManager.authenticateForKeychain() else { return }

        do {
            guard let keyData = try KeychainService.shared.loadBiometricKey(context: context) else { return }
            let key = SymmetricKey(data: keyData)

            // Verify the key is correct
            guard let verification = try KeychainService.shared.loadVerificationData(),
                  VaultCrypto.verifyKey(key, against: verification) else { return }

            appState.unlock(with: key)
        } catch {
            // Biometric unlock failed silently — user can still use password
        }
    }
}
