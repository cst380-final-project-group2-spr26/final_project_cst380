//
//  HomeView.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/18/26.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Sports Buddy Finder")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Home page placeholder")
                    .foregroundStyle(.secondary)

                Button("Log Out") {
                    logOut()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    HomeView(isLoggedIn: .constant(true))
}
