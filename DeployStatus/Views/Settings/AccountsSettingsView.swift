import SwiftUI

/// Settings view for managing accounts
struct AccountsSettingsView: View {
    @Environment(DeploymentStore.self) private var store
    @State private var isAddingAccount = false
    @State private var selectedService: Service = .vercel
    @State private var token = ""
    @State private var accountName = ""
    @State private var isValidating = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Connected accounts
            if !store.accounts.isEmpty {
                Text("Connected Accounts")
                    .font(.headline)

                ForEach(store.accounts) { account in
                    AccountRow(account: account) {
                        do {
                            try store.removeAccount(account.id)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }

            // Add account section
            Divider()

            if isAddingAccount {
                addAccountForm
            } else {
                Button("Add Account") {
                    isAddingAccount = true
                    resetForm()
                }
                .buttonStyle(.borderedProminent)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }

    @ViewBuilder
    private var addAccountForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Account")
                .font(.headline)

            // Service picker
            Picker("Service", selection: $selectedService) {
                ForEach(Service.allCases) { service in
                    HStack {
                        ServiceIcon(service: service)
                        Text(service.displayName)
                    }
                    .tag(service)
                }
            }
            .pickerStyle(.segmented)

            // Account name
            TextField("Account Name (optional)", text: $accountName)
                .textFieldStyle(.roundedBorder)

            // Token input
            TokenInputField(token: $token, service: selectedService, isLoading: isValidating)

            // Buttons
            HStack {
                Button("Cancel") {
                    isAddingAccount = false
                    resetForm()
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Add") {
                    Task {
                        await addAccount()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(token.isEmpty || isValidating)
                .keyboardShortcut(.return)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func resetForm() {
        selectedService = .vercel
        token = ""
        accountName = ""
        errorMessage = nil
    }

    private func addAccount() async {
        isValidating = true
        errorMessage = nil

        let name = accountName.isEmpty ? selectedService.displayName : accountName
        let account = Account(service: selectedService, name: name)

        do {
            try await store.addAccount(account, token: token)
            isAddingAccount = false
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }

        isValidating = false
    }
}

/// Single account row in the list
struct AccountRow: View {
    let account: Account
    let onRemove: () -> Void

    @State private var showRemoveConfirmation = false

    var body: some View {
        HStack {
            ServiceIcon(service: account.service)

            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.body)

                Text(account.service.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                showRemoveConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .help("Remove account")
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .confirmationDialog(
            "Remove \(account.name)?",
            isPresented: $showRemoveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                onRemove()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the account and its API token from your keychain.")
        }
    }
}

#Preview {
    AccountsSettingsView()
        .environment(DeploymentStore())
}
