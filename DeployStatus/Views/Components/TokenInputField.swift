import SwiftUI

/// Secure text field for entering API tokens
struct TokenInputField: View {
    @Binding var token: String
    let service: Service
    var isLoading: Bool = false

    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Group {
                    if isRevealed {
                        TextField(service.tokenPlaceholder, text: $token)
                    } else {
                        SecureField(service.tokenPlaceholder, text: $token)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .disabled(isLoading)

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(isRevealed ? "Hide token" : "Show token")
            }

            Text(service.tokenInstructions)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TokenInputField(token: .constant(""), service: .vercel)
        TokenInputField(token: .constant("test-token-123"), service: .netlify, isLoading: true)
    }
    .padding()
    .frame(width: 400)
}
