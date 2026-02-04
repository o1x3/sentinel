import SwiftData
import SwiftUI

@main
struct SentinelApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var appState = AppState()
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"

    private var resolvedColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
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
            ZStack {
                Group {
                    if appState.isFirstLaunch {
                        SetupView()
                    } else if !appState.isUnlocked {
                        LockView()
                    } else {
                        TOTPListView()
                    }
                }
                .environment(appState)
                .onAppear {
                    LockViewModel().checkFirstLaunch(appState: appState)
                }

                // Blur overlay when app is in background/app switcher
                if appState.isObscured {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(resolvedColorScheme)
            .animation(.easeInOut(duration: 0.2), value: appState.isObscured)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background, .inactive:
                appState.didEnterBackground()
            case .active:
                appState.willEnterForeground()
            @unknown default:
                break
            }
        }
    }
}
