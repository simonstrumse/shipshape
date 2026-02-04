import Foundation
import Observation

/// Overall app status for the menubar icon
enum OverallStatus: Equatable {
    case idle       // No accounts or no recent activity
    case ready      // All recent deploys succeeded
    case building   // At least one deploy in progress
    case error      // At least one recent deploy failed

    var menubarIconName: String {
        switch self {
        case .idle: return "circle"
        case .ready: return "circle.fill"
        case .building: return "circle.fill"
        case .error: return "circle.fill"
        }
    }

    var menubarIconColor: String {
        switch self {
        case .idle: return "gray"
        case .ready: return "green"
        case .building: return "yellow"
        case .error: return "red"
        }
    }
}

/// Central state container for the app
@Observable
final class DeploymentStore {
    // MARK: - State

    private(set) var accounts: [Account] = []
    private(set) var projects: [Project] = []
    private(set) var isLoading = false
    private(set) var lastUpdated: Date?
    private(set) var error: Error?

    /// Demo mode shows sample data instead of real accounts
    var isDemoMode: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.demoMode) }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.demoMode)
            if newValue {
                loadDemoData()
            } else {
                // Clear demo data, reload real accounts
                projects.removeAll()
                accounts.removeAll()
                loadAccounts()
                Task { await refresh() }
            }
        }
    }

    // MARK: - Services

    private let vercelService = VercelService()
    private let netlifyService = NetlifyService()
    private let keychain = KeychainHelper.shared

    // MARK: - Computed Properties

    var overallStatus: OverallStatus {
        if accounts.isEmpty {
            return .idle
        }

        // Only reflect status of projects in the Active section (building or last hour)
        // Old errors shouldn't make the menubar red — only actionable, recent activity matters
        let hasError = activeProjects.contains { $0.latestStatus == .error }
        let hasBuilding = activeProjects.contains { $0.latestStatus == .building || $0.latestStatus == .queued }

        if hasError { return .error }
        if hasBuilding { return .building }
        if activeProjects.isEmpty { return .idle }
        return .ready
    }

    var vercelProjects: [Project] {
        projects.filter { $0.service == .vercel }
    }

    var netlifyProjects: [Project] {
        projects.filter { $0.service == .netlify }
    }

    var hasActiveBuilds: Bool {
        projects.contains { $0.latestStatus == .building || $0.latestStatus == .queued }
    }

    /// Projects that are currently building or had recent activity (last hour)
    var activeProjects: [Project] {
        let oneHourAgo = Date().addingTimeInterval(-3600)

        return projects.filter { project in
            guard let deployment = project.latestDeployment else { return false }

            // Currently building or queued
            if deployment.status == .building || deployment.status == .queued {
                return true
            }

            // Recently finished (within last hour)
            if deployment.createdAt > oneHourAgo {
                return true
            }

            return false
        }.sorted { project1, project2 in
            // Building/queued first, then by recency
            let status1 = project1.latestStatus
            let status2 = project2.latestStatus

            let isActive1 = status1 == .building || status1 == .queued
            let isActive2 = status2 == .building || status2 == .queued

            if isActive1 != isActive2 {
                return isActive1 // Active ones first
            }

            let date1 = project1.latestDeployment?.createdAt ?? .distantPast
            let date2 = project2.latestDeployment?.createdAt ?? .distantPast
            return date1 > date2
        }
    }

    // MARK: - Initialization

    init() {
        if isDemoMode {
            loadDemoData()
        } else {
            loadAccounts()
        }
    }

    // MARK: - Demo Mode

    /// Load sample demo data for screenshots/videos
    private func loadDemoData() {
        let demoAccountId = UUID()

        // Demo accounts
        accounts = [
            Account(id: demoAccountId, service: .vercel, name: "Demo Vercel"),
            Account(id: UUID(), service: .netlify, name: "Demo Netlify")
        ]

        let now = Date()

        // Demo projects with various states
        projects = [
            // Building project (Vercel)
            Project(
                id: "prj_building",
                accountId: demoAccountId,
                service: .vercel,
                name: "acme-website",
                url: "https://acme-website.vercel.app",
                adminUrl: "https://vercel.com/demo/acme-website",
                framework: "Next.js",
                deployments: [
                    Deployment(
                        id: "dpl_building",
                        projectId: "prj_building",
                        service: .vercel,
                        status: .building,
                        url: nil,
                        adminUrl: "https://vercel.com/demo/acme-website/deployments/dpl_building",
                        createdAt: now.addingTimeInterval(-45),
                        readyAt: nil,
                        branch: "main",
                        commitMessage: "feat: add new landing page",
                        commitSha: "a1b2c3d4e5f6789",
                        errorMessage: nil
                    )
                ]
            ),

            // Recently succeeded (Vercel)
            Project(
                id: "prj_docs",
                accountId: demoAccountId,
                service: .vercel,
                name: "docs-site",
                url: "https://docs.acme.dev",
                adminUrl: "https://vercel.com/demo/docs-site",
                framework: "Astro",
                deployments: [
                    Deployment(
                        id: "dpl_docs",
                        projectId: "prj_docs",
                        service: .vercel,
                        status: .ready,
                        url: "https://docs-abc123.vercel.app",
                        adminUrl: "https://vercel.com/demo/docs-site/deployments/dpl_docs",
                        createdAt: now.addingTimeInterval(-600),
                        readyAt: now.addingTimeInterval(-510),
                        branch: "main",
                        commitMessage: "docs: update API reference",
                        commitSha: "f1e2d3c4b5a6789",
                        errorMessage: nil
                    )
                ]
            ),

            // Queued (Netlify)
            Project(
                id: "prj_blog",
                accountId: demoAccountId,
                service: .netlify,
                name: "company-blog",
                url: "https://blog.acme.dev",
                adminUrl: "https://app.netlify.com/sites/company-blog",
                framework: "Gatsby",
                deployments: [
                    Deployment(
                        id: "dpl_blog",
                        projectId: "prj_blog",
                        service: .netlify,
                        status: .queued,
                        url: nil,
                        adminUrl: "https://app.netlify.com/sites/company-blog/deploys/dpl_blog",
                        createdAt: now.addingTimeInterval(-10),
                        readyAt: nil,
                        branch: "main",
                        commitMessage: "post: weekly update",
                        commitSha: "9876543210abcdef",
                        errorMessage: nil
                    )
                ]
            ),

            // Error state (for demo variety)
            Project(
                id: "prj_api",
                accountId: demoAccountId,
                service: .vercel,
                name: "api-server",
                url: "https://api.acme.dev",
                adminUrl: "https://vercel.com/demo/api-server",
                framework: "Node.js",
                deployments: [
                    Deployment(
                        id: "dpl_api",
                        projectId: "prj_api",
                        service: .vercel,
                        status: .error,
                        url: nil,
                        adminUrl: "https://vercel.com/demo/api-server/deployments/dpl_api",
                        createdAt: now.addingTimeInterval(-1800),
                        readyAt: nil,
                        branch: "feature/auth",
                        commitMessage: "wip: oauth integration",
                        commitSha: "deadbeef12345678",
                        errorMessage: "Build failed: Missing env variable"
                    )
                ]
            ),

            // Skipped monorepo build
            Project(
                id: "prj_admin",
                accountId: demoAccountId,
                service: .vercel,
                name: "admin-dashboard",
                url: "https://admin.acme.dev",
                adminUrl: "https://vercel.com/demo/admin-dashboard",
                framework: "React",
                deployments: [
                    Deployment(
                        id: "dpl_admin",
                        projectId: "prj_admin",
                        service: .vercel,
                        status: .skipped,
                        url: nil,
                        adminUrl: "https://vercel.com/demo/admin-dashboard/deployments/dpl_admin",
                        createdAt: now.addingTimeInterval(-300),
                        readyAt: nil,
                        branch: "main",
                        commitMessage: "chore: update deps (no changes)",
                        commitSha: "cafe123456789abc",
                        errorMessage: nil
                    )
                ]
            ),

            // Ready Netlify site
            Project(
                id: "prj_landing",
                accountId: demoAccountId,
                service: .netlify,
                name: "landing-page",
                url: "https://acme.dev",
                adminUrl: "https://app.netlify.com/sites/landing-page",
                framework: "HTML",
                deployments: [
                    Deployment(
                        id: "dpl_landing",
                        projectId: "prj_landing",
                        service: .netlify,
                        status: .ready,
                        url: "https://landing-page--deploy-preview.netlify.app",
                        adminUrl: "https://app.netlify.com/sites/landing-page/deploys/dpl_landing",
                        createdAt: now.addingTimeInterval(-7200),
                        readyAt: now.addingTimeInterval(-7100),
                        branch: "main",
                        commitMessage: "style: hero section redesign",
                        commitSha: "babe456789abcdef",
                        errorMessage: nil
                    )
                ]
            )
        ]

        lastUpdated = now
    }

    // MARK: - Account Management

    /// Add a new account with the given token
    func addAccount(_ account: Account, token: String) async throws {
        // Validate token first
        let isValid: Bool
        switch account.service {
        case .vercel:
            isValid = try await vercelService.validateToken(token)
        case .netlify:
            isValid = try await netlifyService.validateToken(token)
        }

        guard isValid else {
            throw APIError.invalidToken
        }

        // Store token in keychain
        try keychain.save(token: token, for: account.keychainKey)

        // Add to accounts
        accounts.append(account)
        saveAccounts()

        // Fetch projects for the new account
        await refreshAccount(account.id)
    }

    /// Remove an account and its associated data
    func removeAccount(_ accountId: UUID) throws {
        guard let account = accounts.first(where: { $0.id == accountId }) else {
            return
        }

        // Remove token from keychain
        try keychain.delete(for: account.keychainKey)

        // Remove projects
        projects.removeAll { $0.accountId == accountId }

        // Remove account
        accounts.removeAll { $0.id == accountId }
        saveAccounts()
    }

    /// Toggle account enabled state
    func toggleAccount(_ accountId: UUID) {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            return
        }
        accounts[index].isEnabled.toggle()
        saveAccounts()
    }

    // MARK: - Data Refresh

    /// Refresh all data from all enabled accounts
    func refresh() async {
        isLoading = true
        error = nil

        await withTaskGroup(of: Void.self) { group in
            for account in accounts where account.isEnabled {
                group.addTask {
                    await self.refreshAccount(account.id)
                }
            }
        }

        lastUpdated = Date()
        isLoading = false
    }

    /// Refresh data for a specific account
    @discardableResult
    func refreshAccount(_ accountId: UUID) async -> [Project] {
        guard let account = accounts.first(where: { $0.id == accountId }),
              let token = try? keychain.load(for: account.keychainKey) else {
            return []
        }

        do {
            var fetchedProjects: [Project]

            switch account.service {
            case .vercel:
                fetchedProjects = try await vercelService.fetchProjects(token: token, accountId: accountId)

                // Fetch deployments for each project in parallel
                await withTaskGroup(of: (String, [Deployment]).self) { group in
                    for project in fetchedProjects {
                        group.addTask {
                            let deployments = (try? await self.vercelService.fetchDeployments(
                                token: token,
                                accountId: accountId,
                                projectId: project.id
                            )) ?? []
                            return (project.id, deployments)
                        }
                    }

                    for await (projectId, deployments) in group {
                        if let index = fetchedProjects.firstIndex(where: { $0.id == projectId }) {
                            // Sort deployments by date (newest first)
                            fetchedProjects[index].deployments = deployments.sorted { $0.createdAt > $1.createdAt }
                        }
                    }
                }

            case .netlify:
                fetchedProjects = try await netlifyService.fetchSites(token: token, accountId: accountId)

                // Fetch deployments for each site in parallel
                await withTaskGroup(of: (String, [Deployment]).self) { group in
                    for project in fetchedProjects {
                        group.addTask {
                            let deployments = (try? await self.netlifyService.fetchDeploys(
                                token: token,
                                siteId: project.id
                            )) ?? []
                            return (project.id, deployments)
                        }
                    }

                    for await (projectId, deployments) in group {
                        if let index = fetchedProjects.firstIndex(where: { $0.id == projectId }) {
                            // Sort deployments by date (newest first)
                            fetchedProjects[index].deployments = deployments.sorted { $0.createdAt > $1.createdAt }
                        }
                    }
                }
            }

            // Update projects (replace existing for this account)
            projects.removeAll { $0.accountId == accountId }
            projects.append(contentsOf: fetchedProjects)

            // Sort by most recent deployment (latest first)
            projects.sort { project1, project2 in
                let date1 = project1.latestDeployment?.createdAt ?? .distantPast
                let date2 = project2.latestDeployment?.createdAt ?? .distantPast
                return date1 > date2
            }

            return fetchedProjects

        } catch {
            self.error = error
            return []
        }
    }

    // MARK: - Persistence

    private func loadAccounts() {
        guard let data = UserDefaults.standard.data(forKey: Constants.UserDefaultsKeys.accounts),
              let decoded = try? JSONDecoder().decode([Account].self, from: data) else {
            return
        }
        accounts = decoded
    }

    private func saveAccounts() {
        guard let data = try? JSONEncoder().encode(accounts) else {
            return
        }
        UserDefaults.standard.set(data, forKey: Constants.UserDefaultsKeys.accounts)
    }
}
