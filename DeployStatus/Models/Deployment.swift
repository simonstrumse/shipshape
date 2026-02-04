import SwiftUI

/// Represents a deployment from Vercel or Netlify
struct Deployment: Identifiable, Equatable {
    let id: String
    let projectId: String
    let service: Service
    let status: DeploymentStatus
    let url: String?
    let adminUrl: String
    let createdAt: Date
    let readyAt: Date?
    let branch: String?
    let commitMessage: String?
    let commitSha: String?
    let errorMessage: String?

    /// Build duration in seconds
    var buildDuration: TimeInterval? {
        guard let readyAt else { return nil }
        return readyAt.timeIntervalSince(createdAt)
    }

    /// Formatted build duration (e.g., "2m 30s")
    var formattedBuildDuration: String? {
        guard let duration = buildDuration else { return nil }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    /// Short commit SHA (first 7 characters)
    var shortCommitSha: String? {
        guard let sha = commitSha else { return nil }
        return String(sha.prefix(7))
    }
}

/// Deployment status enum
enum DeploymentStatus: String, Codable, Equatable {
    case queued
    case building
    case ready
    case error
    case canceled
    case skipped  // Monorepo deploy with no changes

    var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .building: return "Building"
        case .ready: return "Ready"
        case .error: return "Failed"
        case .canceled: return "Canceled"
        case .skipped: return "Skipped"
        }
    }

    var color: Color {
        switch self {
        case .queued: return .gray
        case .building: return .yellow
        case .ready: return .green
        case .error: return .red
        case .canceled: return .gray
        case .skipped: return .gray
        }
    }

    var iconName: String {
        switch self {
        case .queued: return "clock"
        case .building: return "arrow.triangle.2.circlepath"
        case .ready: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .canceled: return "minus.circle.fill"
        case .skipped: return "forward.fill"
        }
    }

    /// Whether this status represents a terminal (completed) state
    var isTerminal: Bool {
        switch self {
        case .ready, .error, .canceled, .skipped: return true
        case .queued, .building: return false
        }
    }

    /// Whether this status represents an active (in-progress) state
    var isActive: Bool {
        switch self {
        case .queued, .building: return true
        case .ready, .error, .canceled, .skipped: return false
        }
    }
}
