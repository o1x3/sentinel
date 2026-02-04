import SwiftData
import SwiftUI
import UIKit

struct TOTPListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.editMode) private var editMode
    @Environment(AppState.self) private var appState
    @Query private var accounts: [TOTPAccount]
    @State private var viewModel = TOTPViewModel()
    @State private var showingAdd = false
    @State private var searchText = ""
    @State private var editingAccount: TOTPAccount?

    // MARK: - Computed lists

    private var filteredAccounts: [TOTPAccount] {
        let sorted = accounts.sorted { $0.position < $1.position }
        guard !searchText.isEmpty else { return sorted }
        return sorted.filter {
            $0.issuer.localizedCaseInsensitiveContains(searchText)
                || $0.label.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var favoriteAccounts: [TOTPAccount] {
        filteredAccounts.filter(\.isFavorite)
    }

    private var otherAccounts: [TOTPAccount] {
        filteredAccounts.filter { !$0.isFavorite }
    }

    // MARK: - Body

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
            .searchable(text: $searchText, prompt: "Search accounts")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 12) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        if !accounts.isEmpty {
                            EditButton()
                        }
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
            .sheet(item: $editingAccount) { account in
                EditAccountView(account: account)
            }
            .onAppear { viewModel.startTimer() }
            .onDisappear { viewModel.stopTimer() }
        }
    }

    // MARK: - Empty state

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

    // MARK: - Account list

    private var accountList: some View {
        List {
            if !favoriteAccounts.isEmpty {
                ForEach(favoriteAccounts) { account in
                    totpRow(for: account)
                }
                .onMove { source, destination in
                    moveAccounts(source, to: destination, in: favoriteAccounts)
                }
            }

            ForEach(otherAccounts) { account in
                totpRow(for: account)
            }
            .onMove { source, destination in
                moveAccounts(source, to: destination, in: otherAccounts)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Row

    private func totpRow(for account: TOTPAccount) -> some View {
        HStack(spacing: 12) {
            ServiceIconView(
                name: account.issuer.isEmpty ? account.label : account.issuer,
                colorOverride: account.color
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(account.issuer.isEmpty ? account.label : account.issuer)
                        .font(.headline)
                    if account.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }

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
        .contextMenu {
            Button {
                copyCode(for: account)
            } label: {
                Label("Copy Code", systemImage: "doc.on.doc")
            }

            Button {
                editingAccount = account
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                toggleFavorite(account)
            } label: {
                Label(
                    account.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: account.isFavorite ? "star.slash" : "star"
                )
            }

            Divider()

            Button(role: .destructive) {
                modelContext.delete(account)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                copyCode(for: account)
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                modelContext.delete(account)
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                toggleFavorite(account)
            } label: {
                Label(
                    account.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: account.isFavorite ? "star.slash" : "star.fill"
                )
            }
            .tint(.yellow)
        }
    }

    // MARK: - Actions

    private func copyCode(for account: TOTPAccount) {
        guard let key = appState.cryptoKey else { return }
        let code = viewModel.generateCode(for: account, using: key)
        ClipboardService.copy(code)
    }

    private func toggleFavorite(_ account: TOTPAccount) {
        account.isFavorite.toggle()
        // Move to end of the target group
        let targetGroup = account.isFavorite ? favoriteAccounts : otherAccounts
        let maxPos = targetGroup.map(\.position).max() ?? -1
        account.position = maxPos + 1
        account.updatedAt = Date()
    }

    private func moveAccounts(_ source: IndexSet, to destination: Int, in group: [TOTPAccount]) {
        var reordered = group
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, account) in reordered.enumerated() {
            account.position = index
        }
    }
}
