import AppKit
import Foundation
import UserNotifications

/// Manages local notifications for deployment events
final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    // MARK: - User Preferences

    var notificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notificationsEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.notificationsEnabled) }
    }

    var notifyOnBuildStart: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notifyOnBuildStart) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.notifyOnBuildStart) }
    }

    var notifyOnBuildSuccess: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notifyOnBuildSuccess) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.notifyOnBuildSuccess) }
    }

    var notifyOnBuildFailure: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.notifyOnBuildFailure) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.notifyOnBuildFailure) }
    }

    // MARK: - Initialization

    override init() {
        super.init()

        // Set defaults if not set
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Constants.UserDefaultsKeys.notificationsEnabled) == nil {
            defaults.set(true, forKey: Constants.UserDefaultsKeys.notificationsEnabled)
        }
        if defaults.object(forKey: Constants.UserDefaultsKeys.notifyOnBuildStart) == nil {
            defaults.set(true, forKey: Constants.UserDefaultsKeys.notifyOnBuildStart)
        }
        if defaults.object(forKey: Constants.UserDefaultsKeys.notifyOnBuildSuccess) == nil {
            defaults.set(true, forKey: Constants.UserDefaultsKeys.notifyOnBuildSuccess)
        }
        if defaults.object(forKey: Constants.UserDefaultsKeys.notifyOnBuildFailure) == nil {
            defaults.set(true, forKey: Constants.UserDefaultsKeys.notifyOnBuildFailure)
        }

        center.delegate = self
    }

    // MARK: - Permission

    /// Request notification permission
    func requestPermission() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// Check current authorization status
    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Notifications

    /// Send notification for build started
    func notifyBuildStarted(project: Project) {
        guard notificationsEnabled, notifyOnBuildStart else { return }
        guard let deployment = project.latestDeployment else { return }

        let content = UNMutableNotificationContent()
        content.title = "Build Started"
        content.body = buildBody(project: project, deployment: deployment)
        content.sound = .default
        content.userInfo = buildUserInfo(project: project, deployment: deployment)

        sendNotification(id: "build-started-\(deployment.id)", content: content)
    }

    /// Send notification for build succeeded
    func notifyBuildSucceeded(project: Project) {
        guard notificationsEnabled, notifyOnBuildSuccess else { return }
        guard let deployment = project.latestDeployment else { return }

        let content = UNMutableNotificationContent()
        content.title = "Deploy Succeeded"

        var body = project.name
        if let duration = deployment.formattedBuildDuration {
            body += " (\(duration))"
        }
        content.body = body
        content.sound = .default
        content.userInfo = buildUserInfo(project: project, deployment: deployment)

        sendNotification(id: "build-succeeded-\(deployment.id)", content: content)
    }

    /// Send notification for build failed
    func notifyBuildFailed(project: Project) {
        guard notificationsEnabled, notifyOnBuildFailure else { return }
        guard let deployment = project.latestDeployment else { return }

        let content = UNMutableNotificationContent()
        content.title = "Deploy Failed"

        var body = project.name
        if let errorMessage = deployment.errorMessage, !errorMessage.isEmpty {
            body += "\n\(errorMessage)"
        }
        content.body = body
        content.sound = .default
        content.userInfo = buildUserInfo(project: project, deployment: deployment)

        sendNotification(id: "build-failed-\(deployment.id)", content: content)
    }

    // MARK: - Private Helpers

    private func buildBody(project: Project, deployment: Deployment) -> String {
        var body = project.name
        if let branch = deployment.branch {
            body += " (\(branch))"
        }
        return body
    }

    private func buildUserInfo(project: Project, deployment: Deployment) -> [String: Any] {
        [
            "projectId": project.id,
            "deploymentId": deployment.id,
            "service": project.service.rawValue,
            "url": deployment.url ?? deployment.adminUrl
        ]
    }

    private func sendNotification(id: String, content: UNMutableNotificationContent) {
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: nil
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Open URL when notification is clicked
        if let urlString = userInfo["url"] as? String,
           let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}
