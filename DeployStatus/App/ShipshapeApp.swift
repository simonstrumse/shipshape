import SwiftUI

/// Main application entry point
/// Shipshape - Monitor your Netlify and Vercel deployments
@main
struct ShipshapeApp: App {
    @State private var store = DeploymentStore()
    @State private var pollingManager: PollingManager?

    var body: some Scene {
        // Menubar
        MenuBarExtra {
            MenuContentView()
                .environment(store)
        } label: {
            menubarLabel
        }
        .menuBarExtraStyle(.window)

        // Settings window
        Settings {
            SettingsView()
                .environment(store)
        }
    }

    @ViewBuilder
    private var menubarLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: store.overallStatus.menubarIconName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(statusColor)

            if store.hasActiveBuilds {
                Text("Building...")
                    .font(.caption)
            }
        }
        .onAppear {
            setupApp()
        }
    }

    private var statusColor: Color {
        switch store.overallStatus {
        case .idle: return .gray
        case .ready: return .green
        case .building: return .yellow
        case .error: return .red
        }
    }

    private func setupApp() {
        // Request notification permission
        Task {
            _ = try? await NotificationManager.shared.requestPermission()
        }

        // Start polling
        pollingManager = PollingManager(store: store)
        pollingManager?.start()

        // Initial data fetch
        Task {
            await store.refresh()
        }
    }
}
