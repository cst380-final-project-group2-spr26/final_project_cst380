//
//  AuthViewModel.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import FirebaseAuth

// ViewModel responsible for handling user authentication logic.
// Manages login state using Firebase Authentication.
class AuthViewModel: ObservableObject {
    // Tracks whether the user is currently logged in
    @Published var isLoggedIn = false

    // Attempts to log in a user with the provided email and password
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            // If login is successful, update UI state on the main thread
            if result != nil {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            }
        }
    }

    // Logs out the current user and updates login state
    func logout() {
        try? Auth.auth().signOut()
        isLoggedIn = false
    }
}
