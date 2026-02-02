import SwiftData
import SwiftUI

@main
struct SentinelApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Credential.self,
            TOTPAccount.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isFirstLaunch {
                    SetupView()
                } else if !appState.isUnlocked {
                    LockView()
                } else {
                    MainTabView()
                }
            }
            .environment(appState)
            .onAppear {
                LockViewModel().checkFirstLaunch(appState: appState)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
