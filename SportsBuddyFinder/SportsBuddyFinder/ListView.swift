//
//  ListView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth

struct ListView: View {
    @EnvironmentObject private var eventStore: EventStore
    @State private var joiningGameIDs: Set<String> = []

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

                        if !eventStore.message.isEmpty {
                            Text(eventStore.message)
                                .foregroundColor(.white)
                                .font(.caption)
                        }

                        if eventStore.events.isEmpty {
                            Text("No games available yet.")
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.top, 40)
                        } else {
                            ForEach(eventStore.events) { event in
                                NavigationLink(
                                        destination: GameDetailView(
                                            event: event,
                                            isJoined: Binding(
                                                get: {
                                                    eventStore.joinedGameIDs.contains(event.id)
                                                },
                                                set: { newValue in
                                                    if newValue {
                                                        eventStore.joinedGameIDs.insert(event.id)
                                                    } else {
                                                        eventStore.joinedGameIDs.remove(event.id)
                                                    }
                                                }
                                            ),
                                            onStatusChange: {
                                                // DO NOTHING (EventStore already updates everything)
                                            }
                                        )
                                    ) {
                                        eventRow(for: event)
                                    }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                eventStore.start()
            }
            .refreshable {
                eventStore.start()
            }
        }
    }

    private func eventRow(for event: SportsEvent) -> some View {
        let currentUid = Auth.auth().currentUser?.uid
        let isHost = event.hostUid == currentUid
        let isJoined = eventStore.joinedGameIDs.contains(event.id)
        let isJoining = joiningGameIDs.contains(event.id)
        let canJoin = !isHost && !isJoined && !isJoining && event.spotsLeft > 0

        return VStack(alignment: .leading, spacing: 10) {
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

            Button {
                joinGame(event)
            } label: {
                Text(joinButtonTitle(isHost: isHost, isJoined: isJoined, isJoining: isJoining, spotsLeft: event.spotsLeft))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canJoin ? Color.green : Color.gray.opacity(0.35))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!canJoin)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func joinButtonTitle(isHost: Bool, isJoined: Bool, isJoining: Bool, spotsLeft: Int) -> String {
        if isHost {
            return "You Created This Game"
        }

        if isJoined {
            return "Joined"
        }

        if isJoining {
            return "Joining..."
        }

        if spotsLeft <= 0 {
            return "Game Full"
        }

        return "Join Game"
    }

    private func joinGame(_ event: SportsEvent) {
        joiningGameIDs.insert(event.id)

        eventStore.message = ""
        eventStore.joinGame(event) { error in
            joiningGameIDs.remove(event.id)
            if let error {
                eventStore.message = error.localizedDescription
            }
        }
    }
}

#Preview {
    ListView()
        .environmentObject(EventStore())
}
