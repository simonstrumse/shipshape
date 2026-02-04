import SwiftUI
import UserNotifications

/// Settings view for notification preferences
struct NotificationsSettingsView: View {
    @State private var notificationsEnabled = NotificationManager.shared.notificationsEnabled
    @State private var notifyOnBuildStart = NotificationManager.shared.notifyOnBuildStart
    @State private var notifyOnBuildSuccess = NotificationManager.shared.notifyOnBuildSuccess
    @State private var notifyOnBuildFailure = NotificationManager.shared.notifyOnBuildFailure
    @State private var permissionStatus: String = "Checking..."

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.headline)

            // Permission status
            HStack {
                Image(systemName: permissionStatus == "Authorized" ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(permissionStatus == "Authorized" ? .green : .orange)

                Text("System Permission: \(permissionStatus)")
                    .font(.caption)

                if permissionStatus != "Authorized" {
                    Button("Request Permission") {
                        Task {
                            _ = try? await NotificationManager.shared.requestPermission()
                            await checkPermission()
                        }
                    }
                    .font(.caption)
                }
            }

            Divider()

            // Enable/disable all
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, newValue in
                    NotificationManager.shared.notificationsEnabled = newValue
                }

            // Individual toggles
            Group {
                Toggle("Build Started", isOn: $notifyOnBuildStart)
                    .onChange(of: notifyOnBuildStart) { _, newValue in
                        NotificationManager.shared.notifyOnBuildStart = newValue
                    }

                Toggle("Build Succeeded", isOn: $notifyOnBuildSuccess)
                    .onChange(of: notifyOnBuildSuccess) { _, newValue in
                        NotificationManager.shared.notifyOnBuildSuccess = newValue
                    }

                Toggle("Build Failed", isOn: $notifyOnBuildFailure)
                    .onChange(of: notifyOnBuildFailure) { _, newValue in
                        NotificationManager.shared.notifyOnBuildFailure = newValue
                    }
            }
            .disabled(!notificationsEnabled)
            .padding(.leading, 20)

            Spacer()

            // Test notification button
            Button("Send Test Notification") {
                sendTestNotification()
            }
            .disabled(!notificationsEnabled)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .task {
            await checkPermission()
        }
    }

    private func checkPermission() async {
        let status = await NotificationManager.shared.checkPermission()
        switch status {
        case .authorized:
            permissionStatus = "Authorized"
        case .denied:
            permissionStatus = "Denied"
        case .notDetermined:
            permissionStatus = "Not Requested"
        case .provisional:
            permissionStatus = "Provisional"
        case .ephemeral:
            permissionStatus = "Ephemeral"
        @unknown default:
            permissionStatus = "Unknown"
        }
    }

    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Shipshape notifications are working!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "test-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    NotificationsSettingsView()
}
