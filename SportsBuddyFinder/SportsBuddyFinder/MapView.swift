//
//  MapView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI

struct MapView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Map View")
                    .font(.title)
                    .foregroundColor(.white)

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 300)
                    .overlay(Text("Map Placeholder").foregroundColor(.white))

                Text("Tap a pin to view game details")
                    .foregroundColor(.white.opacity(0.8))

                Spacer()
            }
            .padding()
        }
    }
}
