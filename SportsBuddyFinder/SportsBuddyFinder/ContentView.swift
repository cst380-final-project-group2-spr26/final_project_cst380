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

    var body: some View {
        Group {
            if isLoggedIn {
                HomeView(isLoggedIn: $isLoggedIn)
            } else {
                RegisterView(isLoggedIn: $isLoggedIn)
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
