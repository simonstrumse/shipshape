import SwiftUI

/// Main content view for the menubar dropdown
struct MenuContentView: View {
    @Environment(DeploymentStore.self) private var store
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Shipshape")
                    .font(.headline)

                Spacer()

                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            if store.accounts.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "cloud.bolt")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("No accounts connected")
                        .font(.headline)

                    Text("Add your Vercel or Netlify account to start monitoring deployments.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Add Account") {
                        openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
            } else if store.isLoading && store.projects.isEmpty {
                // Loading state
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading projects...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
            } else {
                // Project list
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Active section (building + recent)
                        if !store.activeProjects.isEmpty {
                            ActiveSectionView(projects: store.activeProjects)

                            Divider()
                                .padding(.horizontal, 8)
                        }

                        // Vercel section
                        if !store.vercelProjects.isEmpty || store.accounts.contains(where: { $0.service == .vercel }) {
                            ServiceSectionView(
                                service: .vercel,
                                projects: store.vercelProjects
                            )
                        }

                        // Netlify section
                        if !store.netlifyProjects.isEmpty || store.accounts.contains(where: { $0.service == .netlify }) {
                            if !store.vercelProjects.isEmpty || store.accounts.contains(where: { $0.service == .vercel }) {
                                Divider()
                                    .padding(.horizontal, 8)
                            }

                            ServiceSectionView(
                                service: .netlify,
                                projects: store.netlifyProjects
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 400)
            }

            Divider()

            // Footer
            HStack {
                if let lastUpdated = store.lastUpdated {
                    Text("Updated \(lastUpdated.shortRelativeString)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                } else {
                    Text("Not updated")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                if store.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Button {
                        Task {
                            await store.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Quit button
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack {
                    Text("Quit Shipshape")
                    Spacer()
                    Text("⌘Q")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
    }
}

#Preview {
    MenuContentView()
        .environment(DeploymentStore())
}
