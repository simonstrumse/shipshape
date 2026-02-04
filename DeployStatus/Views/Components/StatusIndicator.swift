import SwiftUI

/// A colored status indicator dot
struct StatusIndicator: View {
    let status: DeploymentStatus
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: size, height: size)
            .overlay {
                if status == .building {
                    Circle()
                        .stroke(status.color.opacity(0.5), lineWidth: 2)
                        .frame(width: size + 4, height: size + 4)
                        .opacity(0.8)
                }
            }
    }
}

/// Larger status badge with icon
struct StatusBadge: View {
    let status: DeploymentStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.caption2)

            Text(status.displayName)
                .font(.caption)
        }
        .foregroundStyle(status.color)
    }
}

/// Service icon view
struct ServiceIcon: View {
    let service: Service
    var size: CGFloat = 12

    var body: some View {
        Image(systemName: service.iconName)
            .font(.system(size: size))
            .foregroundStyle(service.accentColor)
    }
}

#Preview("Status Indicators") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ForEach([DeploymentStatus.queued, .building, .ready, .error, .canceled], id: \.self) { status in
                VStack {
                    StatusIndicator(status: status)
                    Text(status.displayName)
                        .font(.caption)
                }
            }
        }

        Divider()

        HStack(spacing: 20) {
            ForEach([DeploymentStatus.queued, .building, .ready, .error, .canceled], id: \.self) { status in
                StatusBadge(status: status)
            }
        }

        Divider()

        HStack(spacing: 20) {
            ForEach(Service.allCases) { service in
                ServiceIcon(service: service, size: 20)
            }
        }
    }
    .padding()
}
