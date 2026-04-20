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

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            ListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }

            CreateView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }

            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
