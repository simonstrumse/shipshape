import SwiftUI

/// A section in the menu showing projects for a specific service
struct ServiceSectionView: View {
    let service: Service
    let projects: [Project]
    @State private var isExpanded = true
    @State private var showAll = false

    private let initialDisplayCount = 20

    /// Projects to display based on showAll state
    private var displayedProjects: [Project] {
        if showAll || projects.count <= initialDisplayCount {
            return projects
        }
        return Array(projects.prefix(initialDisplayCount))
    }

    /// Number of hidden projects
    private var hiddenCount: Int {
        max(0, projects.count - initialDisplayCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 10)

                ServiceIcon(service: service, size: 12)

                Text(service.displayName)
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
                if projects.isEmpty {
                    Text("No projects found")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 8)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(displayedProjects) { project in
                            ProjectRowView(project: project)
                        }

                        // Show more button
                        if !showAll && hiddenCount > 0 {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showAll = true
                                }
                            } label: {
                                HStack {
                                    Text("Show \(hiddenCount) more...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 32)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ServiceSectionView(
            service: .vercel,
            projects: [
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
                            status: .ready,
                            url: "https://my-app.vercel.app",
                            adminUrl: "https://vercel.com/~/my-app/d1",
                            createdAt: Date().addingTimeInterval(-120),
                            readyAt: Date().addingTimeInterval(-60),
                            branch: "main",
                            commitMessage: "Update",
                            commitSha: "abc123",
                            errorMessage: nil
                        )
                    ]
                )
            ]
        )

        Divider()

        ServiceSectionView(
            service: .netlify,
            projects: []
        )
    }
    .frame(width: 320)
    .padding()
}
