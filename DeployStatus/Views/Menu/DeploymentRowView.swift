import SwiftUI

/// A single deployment row in the menu
struct DeploymentRowView: View {
    let deployment: Deployment
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            StatusIndicator(status: deployment.status, size: 6)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if let sha = deployment.shortCommitSha {
                        Text(sha)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }

                    if let branch = deployment.branch {
                        Text(branch)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if let message = deployment.commitMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                // Build duration for completed deploys
                if let duration = deployment.formattedBuildDuration {
                    Text(duration)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.tertiary)
                    Text("·")
                        .foregroundStyle(.quaternary)
                }
                Text(deployment.createdAt.shortRelativeString)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isHovering ? Color.accentColor.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            openDashboard()
        }
        .contextMenu {
            Button("Open in Dashboard") {
                openDashboard()
            }

            if let url = deployment.url {
                Divider()

                Button("Open Live Site") {
                    if let siteUrl = URL(string: url) {
                        NSWorkspace.shared.open(siteUrl)
                    }
                }

                Button("Copy Site URL") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url, forType: .string)
                }
            }

            if deployment.status == .error {
                Divider()
                Button("View Build Logs") {
                    openDashboard()
                }
            }
        }
    }

    private func openDashboard() {
        if let url = URL(string: deployment.adminUrl) {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        DeploymentRowView(deployment: Deployment(
            id: "1",
            projectId: "proj-1",
            service: .vercel,
            status: .ready,
            url: "https://my-site.vercel.app",
            adminUrl: "https://vercel.com/~/my-site/1",
            createdAt: Date().addingTimeInterval(-120),
            readyAt: Date().addingTimeInterval(-60),
            branch: "main",
            commitMessage: "Update homepage with new design",
            commitSha: "abc123def",
            errorMessage: nil
        ))

        DeploymentRowView(deployment: Deployment(
            id: "2",
            projectId: "proj-1",
            service: .vercel,
            status: .building,
            url: nil,
            adminUrl: "https://vercel.com/~/my-site/2",
            createdAt: Date(),
            readyAt: nil,
            branch: "feature/auth",
            commitMessage: "Add authentication",
            commitSha: "def456ghi",
            errorMessage: nil
        ))

        DeploymentRowView(deployment: Deployment(
            id: "3",
            projectId: "proj-1",
            service: .netlify,
            status: .error,
            url: nil,
            adminUrl: "https://app.netlify.com/sites/my-site/deploys/3",
            createdAt: Date().addingTimeInterval(-3600),
            readyAt: nil,
            branch: "main",
            commitMessage: "Broken build",
            commitSha: "ghi789jkl",
            errorMessage: "Build failed: Module not found"
        ))
    }
    .frame(width: 300)
    .padding()
}
