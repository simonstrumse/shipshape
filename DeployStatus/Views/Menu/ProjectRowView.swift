import SwiftUI

/// A single project row in the menu with expandable deployments
struct ProjectRowView: View {
    let project: Project
    @State private var isExpanded = false
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Project header
            HStack(spacing: 8) {
                // Expand/collapse chevron
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 12)

                // Project name
                Text(project.name)
                    .font(.body)
                    .lineLimit(1)

                Spacer()

                // Status indicator
                if let status = project.latestStatus {
                    StatusBadge(status: status)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(isHovering ? Color.accentColor.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onHover { hovering in
                isHovering = hovering
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
            .contextMenu {
                Button("Open Project") {
                    openProject()
                }

                if let url = project.url {
                    Button("Open Production URL") {
                        if let url = URL(string: url) {
                            NSWorkspace.shared.open(url)
                        }
                    }

                    Button("Copy Production URL") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url, forType: .string)
                    }
                }

                Divider()

                Button("Open in Dashboard") {
                    if let url = URL(string: project.adminUrl) {
                        NSWorkspace.shared.open(url)
                    }
                }
            }

            // Deployments (when expanded)
            if isExpanded && !project.deployments.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(project.deployments) { deployment in
                        DeploymentRowView(deployment: deployment)
                            .padding(.leading, 20)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func openProject() {
        if let url = project.url, let projectUrl = URL(string: url) {
            NSWorkspace.shared.open(projectUrl)
        } else if let adminUrl = URL(string: project.adminUrl) {
            NSWorkspace.shared.open(adminUrl)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ProjectRowView(project: Project(
            id: "1",
            accountId: UUID(),
            service: .vercel,
            name: "my-awesome-project",
            url: "https://my-awesome-project.vercel.app",
            adminUrl: "https://vercel.com/~/my-awesome-project",
            framework: "nextjs",
            deployments: [
                Deployment(
                    id: "d1",
                    projectId: "1",
                    service: .vercel,
                    status: .ready,
                    url: "https://my-awesome-project-abc123.vercel.app",
                    adminUrl: "https://vercel.com/~/my-awesome-project/d1",
                    createdAt: Date().addingTimeInterval(-120),
                    readyAt: Date().addingTimeInterval(-60),
                    branch: "main",
                    commitMessage: "Update homepage",
                    commitSha: "abc123",
                    errorMessage: nil
                ),
                Deployment(
                    id: "d2",
                    projectId: "1",
                    service: .vercel,
                    status: .ready,
                    url: "https://my-awesome-project-def456.vercel.app",
                    adminUrl: "https://vercel.com/~/my-awesome-project/d2",
                    createdAt: Date().addingTimeInterval(-3600),
                    readyAt: Date().addingTimeInterval(-3540),
                    branch: "main",
                    commitMessage: "Fix typo in footer",
                    commitSha: "def456",
                    errorMessage: nil
                )
            ]
        ))

        ProjectRowView(project: Project(
            id: "2",
            accountId: UUID(),
            service: .netlify,
            name: "docs-site",
            url: "https://docs-site.netlify.app",
            adminUrl: "https://app.netlify.com/sites/docs-site",
            framework: nil,
            deployments: [
                Deployment(
                    id: "d3",
                    projectId: "2",
                    service: .netlify,
                    status: .building,
                    url: nil,
                    adminUrl: "https://app.netlify.com/sites/docs-site/deploys/d3",
                    createdAt: Date(),
                    readyAt: nil,
                    branch: "feature/docs",
                    commitMessage: "Add new documentation section",
                    commitSha: "ghi789",
                    errorMessage: nil
                )
            ]
        ))
    }
    .frame(width: 320)
    .padding()
}
