//
//  RegisterView.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/18/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Binding var isLoggedIn: Bool

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var message = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 30))
                            .foregroundColor(.white)

                        Text("Sports Buddy Finder")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)

                    Spacer()

                    VStack(spacing: 20) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Sign up to get started")
                            .foregroundColor(.gray)

                        AuthTextField(placeholder: "Username", text: $username)

                        AuthTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        AuthTextField(placeholder: "Password", text: $password, isSecure: true)

                        AuthTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)

                        Button(action: signUp) {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        NavigationLink("Already have an account? Log In") {
                                LoginView(isLoggedIn: $isLoggedIn)
                        }.font(.footnote)

                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .padding()

                    Spacer()
                }
            }
        }
    }

    func signUp() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty else {
            message = "Please enter a username."
            return
        }

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

            guard let uid = result?.user.uid else {
                message = "Could not get user ID."
                return
            }

            let db = Firestore.firestore()

            db.collection("users").document(uid).setData([
                "username": trimmedUsername,
                "email": trimmedEmail,
                "bio": "",
                "skillLevel": "Beginner",
                "createdAt": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    message = error.localizedDescription
                    return
                }

                message = ""
                isLoggedIn = true
            }
        }
    }
}
