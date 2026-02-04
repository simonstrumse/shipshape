import Foundation

/// Represents a project/site from Vercel or Netlify
struct Project: Identifiable, Equatable {
    let id: String
    let accountId: UUID
    let service: Service
    let name: String
    let url: String?
    let adminUrl: String
    let framework: String?

    var deployments: [Deployment] = []

    /// The most recent deployment's status
    var latestStatus: DeploymentStatus? {
        deployments.first?.status
    }

    /// The most recent deployment
    var latestDeployment: Deployment? {
        deployments.first
    }

    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id &&
        lhs.accountId == rhs.accountId &&
        lhs.service == rhs.service &&
        lhs.name == rhs.name &&
        lhs.url == rhs.url &&
        lhs.adminUrl == rhs.adminUrl &&
        lhs.framework == rhs.framework &&
        lhs.deployments == rhs.deployments
    }
}
