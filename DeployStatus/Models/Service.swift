import SwiftUI

/// Represents a deployment service (Vercel or Netlify)
enum Service: String, Codable, CaseIterable, Identifiable {
    case vercel
    case netlify

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vercel: return "Vercel"
        case .netlify: return "Netlify"
        }
    }

    var iconName: String {
        switch self {
        case .vercel: return "triangle.fill"
        case .netlify: return "leaf.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .vercel: return .primary
        case .netlify: return Color(red: 0.0, green: 0.78, blue: 0.73)
        }
    }

    var tokenInstructions: String {
        switch self {
        case .vercel:
            return "Go to vercel.com → Settings → Tokens → Create Token"
        case .netlify:
            return "Go to app.netlify.com → User Settings → Applications → Personal Access Tokens"
        }
    }

    var tokenPlaceholder: String {
        switch self {
        case .vercel: return "Enter your Vercel token"
        case .netlify: return "Enter your Netlify token"
        }
    }
}
