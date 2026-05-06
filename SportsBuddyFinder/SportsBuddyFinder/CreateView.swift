//
//  CreateView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import CoreLocation

// View that allows users to create and host a new sports game.
// Users can input sport, date/time, and choose a location from a map.

struct CreateView: View {
    // Shared event data and Firebase interaction
    @EnvironmentObject private var eventStore: EventStore
    
    // User input for the type of sport
    @State private var sport = ""
    
    // Selected date and time for the game
    @State private var selectedDate = Date()
    
    // Selected coordinates from the map
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    // Human-readable name of the selected location
    @State private var selectedLocationName = ""
    
    // Controls whether the map picker sheet is shown
    @State private var showingLocationPicker = false
    
    // Displays validation or success messages to the user
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
                    
                    // Input field for sport name
                    AuthTextField(placeholder: "Sport", text: $sport)

                    // Date and time picker for the event
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
                    
                    // Location selection section
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Pick Location on Map") {
                            showingLocationPicker = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)

                        // Show selected location details if available
                        if let coordinate = selectedCoordinate {
                            Text(selectedLocationName.isEmpty ? "Location selected" : selectedLocationName)
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Text("Lat: \(coordinate.latitude), Lng: \(coordinate.longitude)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    // Button to create the game
                    Button("Create Game") {
                        createGame()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    // Display validation or success messages
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
        // Presents map picker for selecting location
        .sheet(isPresented: $showingLocationPicker) {
            LocationPickerView(
                selectedCoordinate: $selectedCoordinate,
                selectedLocationName: $selectedLocationName
            )
        }
    }

    // Validates user input and creates a new game using EventStore
    private func createGame() {
        guard !sport.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            message = "Please enter a sport."
            return
        }

        // Ensure a location has been selected
        guard let coordinate = selectedCoordinate else {
            message = "Please select a location on the map."
            return
        }

        // Call EventStore to create the game in Firebase
        eventStore.createGame(
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

            // Reset form on success
            message = "Game created successfully."
            sport = ""
            selectedDate = Date()
            selectedCoordinate = nil
            selectedLocationName = ""
        }
    }
}
