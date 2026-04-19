//
//  MainTabView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        TabView {

            Text("Map Screen")
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            Text("List Screen")
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }

            Text("Create Screen")
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }

            VStack {
                Text("Profile Screen")

                Button("Log Out") {
                    try? Auth.auth().signOut()
                    isLoggedIn = false
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}
