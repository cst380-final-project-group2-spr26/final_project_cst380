//
//  ListView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI

struct ListView: View {
    @State private var events: [SportsEvent] = []
    @State private var message = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Available Games")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)

                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(.white)
                                .font(.caption)
                        }

                        if events.isEmpty {
                            Text("No games available yet.")
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.top, 40)
                        } else {
                            ForEach(events) { event in
                                eventRow(for: event)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadGames()
            }
        }
    }

    private func loadGames() {
        GameService.shared.fetchGames { result in
            switch result {
            case .success(let loadedEvents):
                events = loadedEvents
                message = ""
            case .failure(let error):
                message = error.localizedDescription
            }
        }
    }

    private func eventRow(for event: SportsEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(event.title)
                    .font(.headline)

                Spacer()

                Text(event.sport)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
            }

            Label(event.time, systemImage: "clock")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Label(event.locationName, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(event.skillLevel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(8)

                Spacer()

                Text("\(event.spotsLeft) spots left")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ListView()
}
