import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: AppStore
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.skyBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("SKY Companion")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(.skyText)
                        Text("Your daily breath practice, guided.")
                            .font(.subheadline)
                            .foregroundColor(.skySub)
                    }
                    .padding(.top, 60)

                    VStack(spacing: 16) {
                        SKYTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SKYTextField(placeholder: "Password", text: $password, isSecure: true)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    SKYPrimaryButton(title: isLoading ? "Signing in…" : "Sign In", disabled: isLoading) {
                        Task { await handleLogin() }
                    }

                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("Don't have an account? ")
                            .foregroundColor(.skySub) +
                        Text("Register")
                            .foregroundColor(.skyIndigo)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
    }

    private func handleLogin() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await store.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
