//
//  SportsBuddyFinderApp.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/18/26.
//

import SwiftUI
import FirebaseCore

// AppDelegate used to configure Firebase when the app launches
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase services
        FirebaseApp.configure()
        return true
    }
}

@main
// Main entry point of the application
struct SportsBuddyFinderApp: App {
    // Connects UIKit AppDelegate to SwiftUI lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            // Root view of the app
            ContentView()
        }
    }
}
