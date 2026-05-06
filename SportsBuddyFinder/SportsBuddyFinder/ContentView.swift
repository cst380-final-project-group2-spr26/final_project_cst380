//
//  ContentView.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/18/26.
//

import SwiftUI
import FirebaseAuth


// Root view that determines whether to show the login screen
// or the main application based on authentication state.
struct ContentView: View {
    // Tracks whether the user is currently logged in
    @State private var isLoggedIn = Auth.auth().currentUser != nil
    
    // Shared app state for events (used across multiple views)
    @StateObject private var eventStore = EventStore()

    var body: some View {
        Group {
            // Show main app if logged in, otherwise show login screen
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
                    .environmentObject(eventStore)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // Ensure login state is synced when app launches
            isLoggedIn = Auth.auth().currentUser != nil
            updateEventStoreSubscription()
        }
        .onChange(of: isLoggedIn) { _, _ in
            updateEventStoreSubscription()
        }
    }

    private func updateEventStoreSubscription() {
        // Starts or stops event data syncing depending on login state
        if isLoggedIn {
            eventStore.start()
        } else {
            eventStore.stop()
        }
    }
}

#Preview {
    ContentView()
}
