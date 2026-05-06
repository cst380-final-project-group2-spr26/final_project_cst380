//
//  RegisterView.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/18/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Registration screen that allows users to create a new account.
// Validates input, creates a Firebase Auth user, and stores user data in Firestore.
struct RegisterView: View {
    
    // Binding used to update global login state after successful registration
    @Binding var isLoggedIn: Bool

    // User input fields
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // Displays validation or error messages
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
                    // App header
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

                    // Registration form
                    VStack(spacing: 20) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Sign up to get started")
                            .foregroundColor(.gray)

                        // Input fields
                        AuthTextField(placeholder: "Username", text: $username)

                        AuthTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        AuthTextField(placeholder: "Password", text: $password, isSecure: true)

                        AuthTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)

                        // Sign-up button
                        Button(action: signUp) {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        // Navigation back to login screen
                        NavigationLink("Already have an account? Log In") {
                                LoginView(isLoggedIn: $isLoggedIn)
                        }.font(.footnote)

                        // Display validation or error message
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

    // Validates user input, creates a Firebase Auth account,
    // and stores additional user data in Firestore
    func signUp() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate input fields
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

        // Create user with Firebase Authentication
        Auth.auth().createUser(withEmail: trimmedEmail, password: password) { result, error in
            if let error = error {
                message = error.localizedDescription
                return
            }

            // Retrieve user ID for Firestore document
            guard let uid = result?.user.uid else {
                message = "Could not get user ID."
                return
            }

            let db = Firestore.firestore()

            // Store additional user data in Firestore
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

                // If successfully registered, then log user in
                message = ""
                isLoggedIn = true
            }
        }
    }
}
