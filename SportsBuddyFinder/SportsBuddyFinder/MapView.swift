//
//  MapView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import MapKit
import FirebaseAuth

struct MapView: View {
    @EnvironmentObject private var eventStore: EventStore

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.6522, longitude: -121.7989),
        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
    )
    @State private var selectedEvent: SportsEvent?
    @State private var joiningEventIDs: Set<String> = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: eventStore.events) { event in
                MapAnnotation(coordinate: event.coordinate) {
                    Button {
                        focus(on: event)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedEvent?.id == event.id ? "figure.run.circle.fill" : "mappin.circle.fill")
                                .font(.system(size: selectedEvent?.id == event.id ? 34 : 28))
                                .foregroundColor(selectedEvent?.id == event.id ? .orange : .blue)
                                .shadow(radius: 4)

                            Text(event.sport)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 12) {
                headerView

                if eventStore.events.isEmpty {
                    Text("No games on the map yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(eventStore.events) { event in
                                Button {
                                    focus(on: event)
                                } label: {
                                    eventCard(for: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                if let selectedEvent {
                    selectedEventPanel(for: selectedEvent)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            eventStore.start()
            syncSelection(with: eventStore.events)
        }
        .onChange(of: eventStore.events) { _, newEvents in
            syncSelection(with: newEvents)
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sports Buddy Finder")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("CSUMB pickup games")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                if let randomEvent = eventStore.events.randomElement() {
                    focus(on: randomEvent)
                }
            } label: {
                Image(systemName: "location.magnifyingglass")
                    .font(.title3)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
            .disabled(eventStore.events.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private func eventCard(for event: SportsEvent) -> some View {
        let isSelected = selectedEvent?.id == event.id
        let isJoined = eventStore.joinedGameIDs.contains(event.id)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isJoined {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Text(event.sport)
                .font(.subheadline)
                .foregroundColor(.orange)

            Text(event.time)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(event.locationName)
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(event.spotsLeft) spots left")
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.14))
                .cornerRadius(8)
        }
        .padding()
        .frame(width: 220, alignment: .leading)
        .background(isSelected ? Color.orange.opacity(0.16) : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.clear, lineWidth: 0)
        )
        .scaleEffect(1.0)
    }

    private func selectedEventPanel(for event: SportsEvent) -> some View {
        let currentUid = Auth.auth().currentUser?.uid
        let isHost = event.hostUid == currentUid
        let isJoined = eventStore.joinedGameIDs.contains(event.id)
        let isJoining = joiningEventIDs.contains(event.id)
        let canJoin = !isHost && !isJoined && !isJoining && event.spotsLeft > 0

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(event.locationName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(event.skillLevel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(12)
            }

            HStack(spacing: 16) {
                Label(event.time, systemImage: "clock")
                    .font(.subheadline)

                Label("\(event.spotsLeft) open", systemImage: "person.3")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)

            if !eventStore.message.isEmpty {
                Text(eventStore.message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 12) {
                Button {
                    joinEvent(event)
                } label: {
                    Text(joinButtonTitle(isHost: isHost, isJoined: isJoined, isJoining: isJoining, spotsLeft: event.spotsLeft))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canJoin ? Color.orange : Color.gray.opacity(0.35))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(!canJoin)

                Button {
                    withAnimation(.easeInOut) {
                        region.center = event.coordinate
                    }
                } label: {
                    Image(systemName: "scope")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                        .background(Color.blue.opacity(0.14))
                        .cornerRadius(14)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(24)
        .padding(.horizontal)
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

    private func joinEvent(_ event: SportsEvent) {
        joiningEventIDs.insert(event.id)
        eventStore.message = ""

        eventStore.joinGame(event) { _ in
            joiningEventIDs.remove(event.id)
        }
    }

    private func focus(on event: SportsEvent) {
        withAnimation(.spring()) {
            selectedEvent = event
            region.center = event.coordinate
        }
    }

    private func syncSelection(with events: [SportsEvent]) {
        guard !events.isEmpty else {
            selectedEvent = nil
            return
        }

        if let selectedEvent,
           let refreshedSelection = events.first(where: { $0.id == selectedEvent.id }) {
            self.selectedEvent = refreshedSelection
            return
        }

        if let newestEvent = events.last {
            focus(on: newestEvent)
        }
    }
}

#Preview {
    MapView()
        .environmentObject(EventStore())
}
