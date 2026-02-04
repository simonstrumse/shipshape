import SwiftUI
import ServiceManagement

/// Settings view for general app preferences
struct GeneralSettingsView: View {
    @Environment(DeploymentStore.self) private var store
    @State private var launchAtLogin = false
    @State private var pollingInterval: PollingInterval = .medium

    var body: some View {
        @Bindable var store = store

        VStack(alignment: .leading, spacing: 16) {
            Text("General")
                .font(.headline)

            // Launch at login
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    setLaunchAtLogin(newValue)
                }

            // Demo mode toggle
            Toggle("Demo Mode", isOn: $store.isDemoMode)
            Text("Show sample data instead of real accounts (for screenshots/videos)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            // Polling interval
            VStack(alignment: .leading, spacing: 8) {
                Text("Check for Updates")
                    .font(.subheadline)

                Picker("Polling Interval", selection: $pollingInterval) {
                    ForEach(PollingInterval.allCases) { interval in
                        Text(interval.displayName).tag(interval)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: pollingInterval) { _, newValue in
                    UserDefaults.standard.set(newValue.rawValue, forKey: Constants.UserDefaultsKeys.pollingInterval)
                }

                Text("More frequent checks use more resources but provide faster updates.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // About section
            VStack(alignment: .leading, spacing: 8) {
                Text("About")
                    .font(.subheadline)

                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Links
            HStack {
                Button("GitHub") {
                    if let url = URL(string: "https://github.com/simonstrumse/shipshape") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)

                Spacer()

                Button("Report Issue") {
                    if let url = URL(string: "https://github.com/simonstrumse/shipshape/issues") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.link)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        // Load launch at login status
        launchAtLogin = SMAppService.mainApp.status == .enabled

        // Load polling interval
        if let rawValue = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.pollingInterval),
           let interval = PollingInterval(rawValue: rawValue) {
            pollingInterval = interval
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }
}

/// Polling interval options
enum PollingInterval: String, CaseIterable, Identifiable {
    case fast = "fast"       // 30 seconds
    case medium = "medium"   // 1 minute
    case slow = "slow"       // 5 minutes

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fast: return "Every 30 seconds"
        case .medium: return "Every minute"
        case .slow: return "Every 5 minutes"
        }
    }

    var interval: TimeInterval {
        switch self {
        case .fast: return 30
        case .medium: return 60
        case .slow: return 300
        }
    }
}

#Preview {
    GeneralSettingsView()
}
