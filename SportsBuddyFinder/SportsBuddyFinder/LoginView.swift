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
            VStack(spacing: 20) {
                Text("Sports Buddy Finder")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Log in to your account")
                    .foregroundStyle(.secondary)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button("Log In") {
                    login()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                NavigationLink("Don't have an account? Sign Up") {
                    RegisterView(isLoggedIn: $isLoggedIn)
                }

                if !message.isEmpty {
                    Text(message)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .padding()
        }
    }

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
