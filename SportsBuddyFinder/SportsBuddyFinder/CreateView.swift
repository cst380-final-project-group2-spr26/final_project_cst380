//
//  CreateView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import CoreLocation

struct CreateView: View {
    @State private var sport = ""
    @State private var selectedDate = Date()
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedLocationName = ""
    @State private var showingLocationPicker = false
    @State private var message = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)

                    Text("Sports Buddy Finder")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 50)

                Spacer()

                VStack(spacing: 20) {
                    Text("Create Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Host a new sports event")
                        .foregroundColor(.gray)

                    AuthTextField(placeholder: "Sport", text: $sport)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Date & Time")
                            .font(.headline)

                        DatePicker(
                            "Game Date and Time",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 8) {
                        Button("Pick Location on Map") {
                            showingLocationPicker = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)

                        if let coordinate = selectedCoordinate {
                            Text(selectedLocationName.isEmpty ? "Location selected" : selectedLocationName)
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Text("Lat: \(coordinate.latitude), Lng: \(coordinate.longitude)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    Button("Create Game") {
                        createGame()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(25)
                .shadow(radius: 10)
                .padding()

                Spacer()
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                selectedCoordinate: $selectedCoordinate,
                selectedLocationName: $selectedLocationName
            )
        }
    }

    private func createGame() {
        guard !sport.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            message = "Please enter a sport."
            return
        }

        guard let coordinate = selectedCoordinate else {
            message = "Please select a location on the map."
            return
        }

        GameService.shared.createGame(
            sport: sport,
            gameDate: selectedDate,
            locationName: selectedLocationName.isEmpty ? "Pinned Location" : selectedLocationName,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) { error in
            if let error = error {
                message = error.localizedDescription
                return
            }

            message = "Game created successfully."
            sport = ""
            selectedDate = Date()
            selectedCoordinate = nil
            selectedLocationName = ""
        }
    }
}
