import Foundation

/// App-wide constants
enum Constants {
    /// API base URLs
    enum API {
        static let vercelBaseURL = URL(string: "https://api.vercel.com")!
        static let netlifyBaseURL = URL(string: "https://api.netlify.com/api/v1")!
    }

    /// Polling intervals in seconds
    enum Polling {
        /// Turbo polling when builds are active (every 10 seconds for near real-time updates)
        static let activeInterval: TimeInterval = 10
        /// Idle polling when no activity (5 minutes to save resources)
        static let idleInterval: TimeInterval = 300
        /// Moderate polling after recent changes (30 seconds)
        static let recentInterval: TimeInterval = 30
        /// How long to consider a change "recent" (3 minutes)
        static let recentChangeDuration: TimeInterval = 180
    }

    /// Keychain configuration (keep old key for data continuity)
    enum Keychain {
        static let service = "com.deploystatus.tokens"
    }

    /// UserDefaults keys (keep old keys for data continuity)
    enum UserDefaultsKeys {
        static let accounts = "deploystatus.accounts"
        static let launchAtLogin = "deploystatus.launchAtLogin"
        static let pollingInterval = "deploystatus.pollingInterval"
        static let notificationsEnabled = "deploystatus.notificationsEnabled"
        static let notifyOnBuildStart = "deploystatus.notifyOnBuildStart"
        static let notifyOnBuildSuccess = "deploystatus.notifyOnBuildSuccess"
        static let notifyOnBuildFailure = "deploystatus.notifyOnBuildFailure"
        static let demoMode = "deploystatus.demoMode"
    }

    /// Number of deployments to fetch per project
    static let deploymentsPerProject = 5
}
