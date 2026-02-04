import Foundation

/// API client for Netlify
actor NetlifyService {
    private let baseURL = Constants.API.netlifyBaseURL
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Public API

    /// Validate a Netlify API token
    func validateToken(_ token: String) async throws -> Bool {
        let url = baseURL.appendingPathComponent("user")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        return httpResponse.statusCode == 200
    }

    /// Fetch all sites for the authenticated user
    func fetchSites(token: String, accountId: UUID) async throws -> [Project] {
        let url = baseURL.appendingPathComponent("sites")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try handleResponse(response)

        let sites = try decode([NetlifySite].self, from: data)
        return sites.map { $0.toProject(accountId: accountId) }
    }

    /// Fetch deployments for a specific site
    func fetchDeploys(
        token: String,
        siteId: String,
        limit: Int = Constants.deploymentsPerProject
    ) async throws -> [Deployment] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("sites/\(siteId)/deploys"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "per_page", value: String(limit))
        ]

        var request = URLRequest(url: components.url!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try handleResponse(response)

        let deploys = try decode([NetlifyDeploy].self, from: data)
        return deploys.map { $0.toDeployment() }
    }

    /// Fetch a specific deployment by ID
    func fetchDeploy(token: String, siteId: String, deployId: String) async throws -> Deployment {
        let url = baseURL.appendingPathComponent("sites/\(siteId)/deploys/\(deployId)")
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try handleResponse(response)

        let deploy = try decode(NetlifyDeploy.self, from: data)
        return deploy.toDeployment()
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

private struct NetlifySite: Decodable {
    let id: String
    let name: String
    let url: String?
    let ssl_url: String?
    let admin_url: String
    let screenshot_url: String?
    let build_settings: BuildSettings?
    let published_deploy: PublishedDeploy?

    struct BuildSettings: Decodable {
        let repo_url: String?
        let repo_branch: String?
    }

    struct PublishedDeploy: Decodable {
        let id: String?
        let state: String?
    }

    func toProject(accountId: UUID) -> Project {
        Project(
            id: id,
            accountId: accountId,
            service: .netlify,
            name: name,
            url: ssl_url ?? url,
            adminUrl: admin_url,
            framework: nil
        )
    }
}

private struct NetlifyDeploy: Decodable {
    let id: String
    let site_id: String
    let name: String?
    let state: String
    let url: String?
    let ssl_url: String?
    let admin_url: String
    let deploy_url: String?
    let created_at: Date
    let updated_at: Date?
    let published_at: Date?
    let title: String?
    let commit_ref: String?
    let commit_url: String?
    let branch: String?
    let error_message: String?
    let context: String?
    let deploy_time: Int?

    func toDeployment() -> Deployment {
        let status = parseStatus(state, errorMessage: error_message, deployTime: deploy_time)
        let readyAt = published_at ?? updated_at

        return Deployment(
            id: id,
            projectId: site_id,
            service: .netlify,
            status: status,
            url: ssl_url ?? url ?? deploy_url,
            adminUrl: admin_url,
            createdAt: created_at,
            readyAt: status == .ready ? readyAt : nil,
            branch: branch,
            commitMessage: title,
            commitSha: commit_ref,
            errorMessage: error_message
        )
    }

    private func parseStatus(_ state: String, errorMessage: String?, deployTime: Int?) -> DeploymentStatus {
        let stateLower = state.lowercased()

        // Check if this is a skipped monorepo build (reports as "error" but is really skipped)
        // Netlify returns state="error" for monorepo deploys with no changes, but:
        // - Real build errors have descriptive error messages
        // - Skipped builds often have nil error message and nil/0 deploy time
        if stateLower == "error" {
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
                // No error message at all - check deploy time
                // Real errors typically have error messages, skipped builds don't
                if deployTime == nil || deployTime == 0 {
                    return .skipped
                }
            }
        }

        switch stateLower {
        case "new", "pending", "uploading", "uploaded", "preparing", "prepared", "enqueued":
            return .queued
        case "building", "processing":
            return .building
        case "ready":
            return .ready
        case "error":
            return .error
        case "skipped":
            return .skipped
        case "canceled":
            return .canceled
        default:
            return .queued
        }
    }
}
