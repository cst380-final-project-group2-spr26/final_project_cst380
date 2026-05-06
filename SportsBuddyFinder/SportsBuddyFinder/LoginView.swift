//
//  LoginView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth

// Login screen that allows users to authenticate using email and password.
// Updates app state upon successful login.
struct LoginView: View {
    
    // Binding used to update global login state
    @Binding var isLoggedIn: Bool

    // User input for email and password
    @State private var email = ""
    @State private var password = ""
    
    // Displays login error messages
    @State private var message = ""

    var body: some View {
        NavigationStack {
            ZStack {
                //background
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    //header
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

                    //login
                    VStack(spacing: 20) {
                        // Login form
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Log in to continue")
                            .foregroundColor(.gray)

                        // Email input
                        AuthTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        // Password input
                        AuthTextField(placeholder: "Password", text: $password, isSecure: true)

                        // Login button
                        Button(action: login) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        // Navigation to registration screen
                        NavigationLink("Don't have an account? Sign Up") {
                            RegisterView(isLoggedIn: $isLoggedIn)
                        }
                        .font(.footnote)

                        // Display error message if login fails
                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.caption)
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

    // Authenticates user with Firebase using email and password
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                message = error.localizedDescription
                return
            }

            // Update login state on success
            message = ""
            isLoggedIn = true
        }
    }
}
