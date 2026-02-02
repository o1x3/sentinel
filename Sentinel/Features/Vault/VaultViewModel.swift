import Foundation
import Observation
import SwiftData

enum VaultFilter: String, CaseIterable {
    case all = "All"
    case logins = "Logins"
    case twoFactor = "2FA"
    case favorites = "Favorites"
}

@Observable
final class VaultViewModel {
    var searchText = ""
    var selectedFilter: VaultFilter = .all

    func filteredCredentials(_ credentials: [Credential], totpAccounts: [TOTPAccount]) -> [Credential] {
        var result = credentials

        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .logins:
            result = result.filter { $0.linkedTOTPId == nil }
        case .twoFactor:
            result = result.filter { $0.linkedTOTPId != nil }
        case .favorites:
            result = result.filter { $0.isFavorite }
        }

        // Apply search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.username.lowercased().contains(query) ||
                $0.urls.contains { $0.lowercased().contains(query) } ||
                ($0.tags.contains { $0.lowercased().contains(query) })
            }
        }

        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func toggleFavorite(_ credential: Credential) {
        credential.isFavorite.toggle()
        credential.updatedAt = Date()
    }

    func delete(_ credential: Credential, from context: ModelContext) {
        context.delete(credential)
    }
}
