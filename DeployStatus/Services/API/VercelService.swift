import Foundation

/// API client for Vercel
actor VercelService {
    private let baseURL = Constants.API.vercelBaseURL
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public API

    /// Validate a Vercel API token
    func validateToken(_ token: String) async throws -> Bool {
        let url = baseURL.appendingPathComponent("v2/user")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        return httpResponse.statusCode == 200
    }

    /// Fetch all projects for the authenticated user
    func fetchProjects(token: String, accountId: UUID) async throws -> [Project] {
        var components = URLComponents(url: baseURL.appendingPathComponent("v9/projects"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "100")
        ]
        var request = URLRequest(url: components.url!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try handleResponse(response)

        let projectsResponse = try decode(VercelProjectsResponse.self, from: data)
        return projectsResponse.projects.map { $0.toProject(accountId: accountId) }
    }

    /// Fetch deployments, optionally filtered by project
    func fetchDeployments(
        token: String,
        accountId: UUID,
        projectId: String? = nil,
        limit: Int = Constants.deploymentsPerProject
    ) async throws -> [Deployment] {
        var components = URLComponents(url: baseURL.appendingPathComponent("v6/deployments"), resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let projectId = projectId {
            queryItems.append(URLQueryItem(name: "projectId", value: projectId))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try handleResponse(response)

        let deploymentsResponse = try decode(VercelDeploymentsResponse.self, from: data)
        return deploymentsResponse.deployments.map { $0.toDeployment() }
    }

    /// Fetch a specific deployment by ID
    func fetchDeployment(token: String, deploymentId: String) async throws -> Deployment {
        let url = baseURL.appendingPathComponent("v13/deployments/\(deploymentId)")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try handleResponse(response)

        let deployment = try decode(VercelDeployment.self, from: data)
        return deployment.toDeployment()
    }

    // MARK: - Private Helpers

    private func handleResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401, 403:
            throw APIError.invalidToken
        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                .flatMap { Double($0) }
            throw APIError.rateLimited(retryAfter: retryAfter)
        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .flexibleISO8601

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.decodingError(underlying: error)
        }
    }
}

// MARK: - Response Models

private struct VercelProjectsResponse: Decodable {
    let projects: [VercelProject]
}

private struct VercelProject: Decodable {
    let id: String
    let name: String
    let framework: String?
    let link: VercelLink?

    struct VercelLink: Decodable {
        let type: String?
        let repo: String?
    }

    func toProject(accountId: UUID) -> Project {
        Project(
            id: id,
            accountId: accountId,
            service: .vercel,
            name: name,
            url: nil,
            adminUrl: "https://vercel.com/~/\(name)",
            framework: framework
        )
    }
}

private struct VercelDeploymentsResponse: Decodable {
    let deployments: [VercelDeployment]
}

private struct VercelDeployment: Decodable {
    let uid: String
    let name: String
    let url: String?
    let state: String?
    let readyState: String?
    let created: Double
    let ready: Double?
    let buildingAt: Double?
    let meta: VercelMeta?
    let errorCode: String?
    let errorMessage: String?

    struct VercelMeta: Decodable {
        let githubCommitSha: String?
        let githubCommitMessage: String?
        let githubCommitRef: String?
        let gitlabCommitSha: String?
        let gitlabCommitMessage: String?
        let gitlabCommitRef: String?
        let bitbucketCommitSha: String?
        let bitbucketCommitMessage: String?
        let bitbucketCommitRef: String?
    }

    func toDeployment() -> Deployment {
        let status = parseStatus(
            state ?? readyState ?? "QUEUED",
            errorMessage: errorMessage,
            buildingAt: buildingAt
        )
        let createdAt = Date(timeIntervalSince1970: created / 1000)
        let readyAt = ready.map { Date(timeIntervalSince1970: $0 / 1000) }

        // Extract git info from meta (supports GitHub, GitLab, Bitbucket)
        let commitSha = meta?.githubCommitSha ?? meta?.gitlabCommitSha ?? meta?.bitbucketCommitSha
        let commitMessage = meta?.githubCommitMessage ?? meta?.gitlabCommitMessage ?? meta?.bitbucketCommitMessage
        let branch = meta?.githubCommitRef ?? meta?.gitlabCommitRef ?? meta?.bitbucketCommitRef

        return Deployment(
            id: uid,
            projectId: name,
            service: .vercel,
            status: status,
            url: url.map { "https://\($0)" },
            adminUrl: "https://vercel.com/~/\(name)/\(uid)",
            createdAt: createdAt,
            readyAt: readyAt,
            branch: branch,
            commitMessage: commitMessage,
            commitSha: commitSha,
            errorMessage: errorMessage
        )
    }

    private func parseStatus(_ state: String, errorMessage: String?, buildingAt: Double?) -> DeploymentStatus {
        let stateUpper = state.uppercased()

        // Check if this is a skipped monorepo build (reports as ERROR but is really skipped)
        // Vercel returns ERROR for monorepo deploys with no changes, but:
        // - Real build errors have error messages and buildingAt timestamps
        // - Skipped builds often have neither
        if stateUpper == "ERROR" {
            // Check for skip-related keywords in error message
            if let message = errorMessage?.lowercased() {
                if message.contains("skipped") ||
                   message.contains("canceled") ||
                   message.contains("no changes") ||
                   message.contains("ignored") ||
                   message.contains("not in scope") {
                    return .skipped
                }
            } else {
                // No error message - check if build ever started
                // Real errors typically have error messages, skipped builds don't
                if buildingAt == nil {
                    return .skipped
                }
            }
        }

        switch stateUpper {
        case "QUEUED", "PENDING", "INITIALIZING":
            return .queued
        case "BUILDING":
            return .building
        case "READY":
            return .ready
        case "ERROR":
            return .error
        case "CANCELED":
            return .canceled
        case "SKIPPED":
            return .skipped
        default:
            return .queued
        }
    }
}
