import SwiftData
import SwiftUI

struct VaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Credential.name) private var credentials: [Credential]
    @Query private var totpAccounts: [TOTPAccount]
    @State private var viewModel = VaultViewModel()
    @State private var showingAddCredential = false

    private var filtered: [Credential] {
        viewModel.filteredCredentials(credentials, totpAccounts: totpAccounts)
    }

    var body: some View {
        NavigationStack {
            Group {
                if credentials.isEmpty {
                    emptyState
                } else {
                    credentialList
                }
            }
            .navigationTitle("Vault")
            .searchable(text: $viewModel.searchText, prompt: "Search credentials")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddCredential = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCredential) {
                CredentialEditView(mode: .create)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Credentials", systemImage: "lock.shield")
        } description: {
            Text("Tap + to add your first credential")
        } actions: {
            Button("Add Credential") {
                showingAddCredential = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var credentialList: some View {
        List {
            filterPicker

            ForEach(filtered) { credential in
                NavigationLink(value: credential.id) {
                    VaultItemRow(credential: credential)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.delete(credential, from: modelContext)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        viewModel.toggleFavorite(credential)
                    } label: {
                        Label(
                            credential.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: credential.isFavorite ? "star.slash" : "star.fill"
                        )
                    }
                    .tint(.yellow)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: UUID.self) { id in
            if let credential = credentials.first(where: { $0.id == id }) {
                CredentialDetailView(credential: credential)
            }
        }
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.selectedFilter) {
            ForEach(VaultFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .padding(.horizontal, -4)
    }
}
