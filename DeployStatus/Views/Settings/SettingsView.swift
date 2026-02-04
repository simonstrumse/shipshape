import SwiftUI

/// Main settings window with tabbed interface
struct SettingsView: View {
    var body: some View {
        TabView {
            AccountsSettingsView()
                .tabItem {
                    Label("Accounts", systemImage: "person.crop.circle")
                }

            NotificationsSettingsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }

            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
        }
        .frame(minWidth: 450, minHeight: 350)
    }
}

#Preview {
    SettingsView()
        .environment(DeploymentStore())
}
