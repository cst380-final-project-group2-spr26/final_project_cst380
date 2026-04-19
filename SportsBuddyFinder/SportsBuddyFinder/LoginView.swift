//
//  LoginView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var isLoggedIn: Bool

    @State private var email = ""
    @State private var password = ""
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
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Log in to continue")
                            .foregroundColor(.gray)

                        AuthTextField(placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        AuthTextField(placeholder: "Password", text: $password, isSecure: true)

                        Button(action: login) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        NavigationLink("Don't have an account? Sign Up") {
                            RegisterView(isLoggedIn: $isLoggedIn)
                        }
                        .font(.footnote)

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

    //Firebase Login
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                message = error.localizedDescription
                return
            }

            message = ""
            isLoggedIn = true
        }
    }
}
