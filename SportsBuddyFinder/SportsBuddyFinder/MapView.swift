//
//  MapView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.6522, longitude: -121.7989),
        span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
    )

    @State private var selectedEvent: SportsEvent?
    @State private var joinedEvents: Set<String> = []

    let events = SportsEvent.sampleEvents

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: events) { event in
                MapAnnotation(coordinate: event.coordinate) {
                    Button {
                        withAnimation(.spring()) {
                            selectedEvent = event
                            region.center = event.coordinate
                        }
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

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(events) { event in
                            Button {
                                withAnimation(.spring()) {
                                    selectedEvent = event
                                    region.center = event.coordinate
                                }
                            } label: {
                                eventCard(for: event)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }

                if let selectedEvent {
                    selectedEventPanel(for: selectedEvent)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            selectedEvent = events.first
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
                withAnimation(.easeInOut) {
                    selectedEvent = events.randomElement()
                    if let selectedEvent {
                        region.center = selectedEvent.coordinate
                    }
                }
            } label: {
                Image(systemName: "location.magnifyingglass")
                    .font(.title3)
                    .padding(10)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private func eventCard(for event: SportsEvent) -> some View {
        let isSelected = selectedEvent?.id == event.id
        let isJoined = joinedEvents.contains(event.id)

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
        let isJoined = joinedEvents.contains(event.id)

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

            Text("This is a rough preview card for the selected event. Tapping map pins or cards updates this panel, and the join button just toggles local UI state for now.")
                .font(.footnote)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring()) {
                        if joinedEvents.contains(event.id) {
                            joinedEvents.remove(event.id)
                        } else {
                            joinedEvents.insert(event.id)
                        }
                    }
                } label: {
                    Text(isJoined ? "Joined" : "Attend Event")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isJoined ? Color.green : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                Button {
                    withAnimation(.easeInOut) {
                        region.center = event.coordinate
                        region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    }
                } label: {
                    Image(systemName: "scope")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                        .background(Color.black.opacity(0.08))
                        .cornerRadius(14)
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    MapView()
}
