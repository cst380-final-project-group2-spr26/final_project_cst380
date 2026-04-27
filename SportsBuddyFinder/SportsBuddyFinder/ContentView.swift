//
//  ContentView.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/18/26.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = Auth.auth().currentUser != nil
    @StateObject private var eventStore = EventStore()

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
                    .environmentObject(eventStore)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            isLoggedIn = Auth.auth().currentUser != nil
        }
    }
}

#Preview {
    ContentView()
}
