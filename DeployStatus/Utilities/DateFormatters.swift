import Foundation

/// Date formatting utilities
extension Date {
    /// Relative time string (e.g., "2m ago", "1h ago", "3d ago")
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Short relative time string for compact display
    var shortRelativeString: String {
        let interval = Date().timeIntervalSince(self)

        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: self)
        }
    }
}

/// ISO 8601 date parsing for API responses
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

/// ISO 8601 decoder for JSON parsing
extension JSONDecoder.DateDecodingStrategy {
    static let flexibleISO8601 = custom { decoder in
        let container = try decoder.singleValueContainer()

        // Try millisecond timestamp first (Vercel uses this)
        if let timestamp = try? container.decode(Double.self) {
            return Date(timeIntervalSince1970: timestamp / 1000)
        }

        // Try ISO 8601 string formats
        let dateString = try container.decode(String.self)

        if let date = DateFormatter.iso8601Full.date(from: dateString) {
            return date
        }
        if let date = DateFormatter.iso8601.date(from: dateString) {
            return date
        }

        // Try ISO 8601 formatter
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode date from: \(dateString)"
        )
    }
}
