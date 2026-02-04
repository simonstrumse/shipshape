import Foundation
import Observation

/// Manages polling for deployment updates with smart intervals
@Observable
final class PollingManager {
    // MARK: - State

    private(set) var isPolling = false
    private(set) var nextPollTime: Date?

    // MARK: - Dependencies

    private let store: DeploymentStore
    private let notificationManager: NotificationManager
    private var pollingTask: Task<Void, Never>?
    private var previousStatuses: [String: DeploymentStatus] = [:]

    // MARK: - Configuration

    private var activeInterval: TimeInterval {
        Constants.Polling.activeInterval
    }

    private var idleInterval: TimeInterval {
        Constants.Polling.idleInterval
    }

    private var recentInterval: TimeInterval {
        Constants.Polling.recentInterval
    }

    private var recentChangeTimestamp: Date?

    /// Current polling interval based on state
    var currentInterval: TimeInterval {
        // If there are active builds, poll frequently
        if store.hasActiveBuilds {
            return activeInterval
        }

        // If there was a recent change, use moderate interval
        if let recent = recentChangeTimestamp,
           Date().timeIntervalSince(recent) < Constants.Polling.recentChangeDuration {
            return recentInterval
        }

        // Otherwise use idle interval
        return idleInterval
    }

    // MARK: - Initialization

    init(store: DeploymentStore, notificationManager: NotificationManager = .shared) {
        self.store = store
        self.notificationManager = notificationManager
    }

    // MARK: - Polling Control

    /// Start polling for updates
    func start() {
        guard !isPolling else { return }
        isPolling = true

        // Capture initial states
        captureCurrentStatuses()

        // Start polling loop
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }

                let interval = self.currentInterval
                self.nextPollTime = Date().addingTimeInterval(interval)

                try? await Task.sleep(for: .seconds(interval))

                if Task.isCancelled { break }

                await self.poll()
            }
        }
    }

    /// Stop polling
    func stop() {
        isPolling = false
        pollingTask?.cancel()
        pollingTask = nil
        nextPollTime = nil
    }

    /// Force an immediate poll
    func pollNow() async {
        await poll()
    }

    // MARK: - Private Methods

    private func poll() async {
        // Capture previous states before refresh
        captureCurrentStatuses()

        // Refresh data
        await store.refresh()

        // Check for changes and notify
        detectChangesAndNotify()
    }

    private func captureCurrentStatuses() {
        previousStatuses = Dictionary(
            store.projects.compactMap { project -> (String, DeploymentStatus)? in
                guard let status = project.latestStatus else { return nil }
                return (project.id, status)
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    private func detectChangesAndNotify() {
        for project in store.projects {
            guard let currentStatus = project.latestStatus else { continue }

            let previousStatus = previousStatuses[project.id]

            // Skip if no change
            if previousStatus == currentStatus { continue }

            // Mark recent change
            recentChangeTimestamp = Date()

            // Notify based on status change
            if previousStatus == nil {
                // New project - only notify if it's building
                if currentStatus == .building {
                    notificationManager.notifyBuildStarted(project: project)
                }
            } else {
                // Status changed
                switch currentStatus {
                case .building:
                    if previousStatus == .queued {
                        notificationManager.notifyBuildStarted(project: project)
                    }
                case .ready:
                    notificationManager.notifyBuildSucceeded(project: project)
                case .error:
                    notificationManager.notifyBuildFailed(project: project)
                case .queued, .canceled, .skipped:
                    break
                }
            }
        }
    }
}
