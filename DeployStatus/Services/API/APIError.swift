import Foundation

/// Unified API error types for Vercel and Netlify
enum APIError: LocalizedError {
    case invalidToken
    case rateLimited(retryAfter: TimeInterval?)
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case serverError(statusCode: Int, message: String?)
    case invalidURL
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid or expired API token. Please check your token in settings."
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Rate limited. Please try again in \(Int(seconds)) seconds."
            }
            return "Rate limited. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            if let message = message {
                return "Server error (\(code)): \(message)"
            }
            return "Server error: \(code)"
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        }
    }

    var isAuthError: Bool {
        switch self {
        case .invalidToken:
            return true
        case .serverError(let code, _):
            return code == 401 || code == 403
        default:
            return false
        }
    }

    var isRateLimitError: Bool {
        if case .rateLimited = self {
            return true
        }
        return false
    }
}
