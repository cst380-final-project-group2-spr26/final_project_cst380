//
//  AuthViewModel.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if result != nil {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            }
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        isLoggedIn = false
    }
}
