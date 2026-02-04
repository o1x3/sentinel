import SwiftData
import SwiftUI
import UIKit

struct TOTPListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \TOTPAccount.issuer) private var accounts: [TOTPAccount]
    @State private var viewModel = TOTPViewModel()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if accounts.isEmpty {
                    emptyState
                } else {
                    accountList
                }
            }
            .navigationTitle("Codes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTOTPView()
            }
            .onAppear { viewModel.startTimer() }
            .onDisappear { viewModel.stopTimer() }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No 2FA Codes", systemImage: "key.viewfinder")
        } description: {
            Text("Tap + to add a two-factor authentication code")
        } actions: {
            Button("Add Code") {
                showingAdd = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var accountList: some View {
        List {
            ForEach(accounts) { account in
                totpRow(for: account)
            }
            .onDelete { offsets in
                for index in offsets {
                    modelContext.delete(accounts[index])
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func totpRow(for account: TOTPAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.issuer.isEmpty ? account.label : account.issuer)
                    .font(.headline)

                if !account.issuer.isEmpty && !account.label.isEmpty {
                    Text(account.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let key = appState.cryptoKey {
                    TOTPCodeView(code: viewModel.generateCode(for: account, using: key))
                        .animation(.default, value: viewModel.secondsRemaining)
                }
            }

            Spacer()

            CircularTimerView(
                remaining: viewModel.secondsRemaining,
                period: account.period
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            copyCode(for: account)
        }
    }

    private func copyCode(for account: TOTPAccount) {
        guard let key = appState.cryptoKey else { return }
        let code = viewModel.generateCode(for: account, using: key)
        UIPasteboard.general.string = code
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
