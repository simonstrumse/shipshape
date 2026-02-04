import SwiftUI

/// Section showing currently building and recently deployed projects
struct ActiveSectionView: View {
    let projects: [Project]
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 10)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.yellow)

                Text("Active")
                    .font(.headline)

                Text("(\(projects.count))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(projects) { project in
                        ActiveProjectRowView(project: project)
                    }
                }
            }
        }
    }
}

/// A project row for the Active section - shows service icon inline
struct ActiveProjectRowView: View {
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

                // Service icon
                Image(systemName: project.service.iconName)
                    .font(.system(size: 10))
                    .foregroundStyle(project.service.accentColor)

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
    ActiveSectionView(projects: [
        Project(
            id: "1",
            accountId: UUID(),
            service: .vercel,
            name: "my-app",
            url: "https://my-app.vercel.app",
            adminUrl: "https://vercel.com/~/my-app",
            framework: "nextjs",
            deployments: [
                Deployment(
                    id: "d1",
                    projectId: "1",
                    service: .vercel,
                    status: .building,
                    url: nil,
                    adminUrl: "https://vercel.com/~/my-app/d1",
                    createdAt: Date(),
                    readyAt: nil,
                    branch: "main",
                    commitMessage: "Update homepage",
                    commitSha: "abc123",
                    errorMessage: nil
                )
            ]
        ),
        Project(
            id: "2",
            accountId: UUID(),
            service: .netlify,
            name: "docs-site",
            url: "https://docs-site.netlify.app",
            adminUrl: "https://app.netlify.com/sites/docs-site",
            framework: nil,
            deployments: [
                Deployment(
                    id: "d2",
                    projectId: "2",
                    service: .netlify,
                    status: .ready,
                    url: "https://docs-site.netlify.app",
                    adminUrl: "https://app.netlify.com/sites/docs-site/deploys/d2",
                    createdAt: Date().addingTimeInterval(-300),
                    readyAt: Date().addingTimeInterval(-240),
                    branch: "main",
                    commitMessage: "Fix typo",
                    commitSha: "def456",
                    errorMessage: nil
                )
            ]
        )
    ])
    .frame(width: 320)
    .padding()
}
