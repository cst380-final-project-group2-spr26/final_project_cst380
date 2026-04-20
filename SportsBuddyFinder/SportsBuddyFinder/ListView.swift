//
//  ListView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI


struct ListView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 15) {
                Text("Available Games")
                    .font(.title)
                    .foregroundColor(.white)

                ForEach(1...3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(height: 70)
                        .overlay(
                            VStack {
                                Text("Game \(i)")
                                Text("5:00 PM • Park")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }

                Spacer()
            }
            .padding()
        }
    }
}
