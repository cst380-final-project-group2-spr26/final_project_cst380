//
//  RegisterView.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/18/26.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @Binding var isLoggedIn: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var message = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sports Buddy Finder")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Create an account to continue")
                    .foregroundStyle(.secondary)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)

                Button("Sign Up") {
                    signUp()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                if !message.isEmpty {
                    Text(message)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
        }
    }

    func signUp() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            message = "Please enter an email."
            return
        }

        guard password.count >= 6 else {
            message = "Password must be at least 6 characters."
            return
        }

        guard password == confirmPassword else {
            message = "Passwords do not match."
            return
        }

        Auth.auth().createUser(withEmail: trimmedEmail, password: password) { result, error in
            if let error = error {
                message = error.localizedDescription
                return
            }

            message = ""
            isLoggedIn = true
        }
    }
}

#Preview {
    RegisterView(isLoggedIn: .constant(false))
}
