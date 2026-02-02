import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            VaultView()
                .tabItem {
                    Label("Vault", systemImage: "lock.shield")
                }

            TOTPListView()
                .tabItem {
                    Label("Codes", systemImage: "key.viewfinder")
                }

            Text("Settings Placeholder") // Replaced in Phase 7
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
