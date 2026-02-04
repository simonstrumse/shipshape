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
        loadAccounts()
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
