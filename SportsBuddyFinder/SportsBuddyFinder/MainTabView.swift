//
//  MainTabView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth

// Main navigation view that provides tab-based access to core app screens.
// Includes Map, List, Create, and Profile sections.
struct MainTabView: View {
    
    // Binding used to update login state (passed to ProfileView for logout)
    @Binding var isLoggedIn: Bool

    var body: some View {
        TabView {

            // Map view for browsing games geographically
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            // List view for browsing games in a scrollable list
            ListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }

            // Screen for creating a new game
            CreateView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }

            // Profile screen (includes logout functionality)
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
