import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var courseCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.skyBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 30, weight: .heavy))
                            .foregroundColor(.skyText)
                        Text("Enter your Art of Living course details.")
                            .font(.subheadline)
                            .foregroundColor(.skySub)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 16) {
                        SKYTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SKYTextField(placeholder: "Password", text: $password, isSecure: true)
                        SKYTextField(placeholder: "Course Code", text: $courseCode)
                            .autocapitalization(.allCharacters)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    SKYPrimaryButton(title: isLoading ? "Creating account…" : "Create Account", disabled: isLoading) {
                        Task { await handleRegister() }
                    }

                    Button("Already have an account? Sign In") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.skySub)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
    }

    private func handleRegister() async {
        guard !email.isEmpty, !password.isEmpty, !courseCode.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await store.register(email: email, password: password, courseCode: courseCode)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
