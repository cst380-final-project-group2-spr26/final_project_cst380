//
//  ProfileView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text("Username")
                    .foregroundColor(.white)

                Text("Games Joined: 3")
                    .foregroundColor(.white.opacity(0.8))

                Button("Log Out") {
                    try? Auth.auth().signOut()
                    isLoggedIn = false
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
    }
}
