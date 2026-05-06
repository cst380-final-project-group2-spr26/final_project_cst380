//
//  GameDetail.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/26/26.
//

import SwiftUI
import EventKit

// Displays detailed information about a selected game.
// Allows users to join/leave the game and add it to their calendar.
struct GameDetailView: View {
    // The selected game being viewed
    let event: SportsEvent
    
    // Tracks whether the current user has joined this game
    @Binding var isJoined: Bool
    
    // Shared app state for updating events and Firebase data
    @EnvironmentObject var eventStore: EventStore
    
    // Callback to notify parent view when join/leave status changes
    let onStatusChange: () -> Void

    // Controls alert for saving to calendar
    @State private var showSavedAlert = false
    
    // Controls confirmation alert for leaving a game
    @State private var showLeaveAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Game title and sport
                VStack(spacing: 6) {
                    Text(event.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(event.sport)
                        .foregroundColor(.orange)
                        .font(.title3)
                }

                // Game details (time, location, spots, skill level)
                VStack(alignment: .leading, spacing: 12) {

                    Label(event.time, systemImage: "clock")

                    Label(event.locationName, systemImage: "mappin.and.ellipse")

                    Label("\(event.spotsLeft) spots left", systemImage: "person.3")

                    Label("Skill: \(event.skillLevel)", systemImage: "flame")

                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 4)

                //Description placeholder
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this game")
                        .font(.headline)

                    Text("Join this game to meet other players and have fun. More features coming soon.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 4)

                // Join / Leave + Calendar actions
                VStack(spacing: 12) {

                    Button {
                        // If already joined, show confirmation before leaving
                        if isJoined {
                            showLeaveAlert = true
                        } else {
                            joinGame()
                        }
                    } label: {
                        Text(isJoined ? "Leave Game" : "Join Game")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isJoined ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
//                    .disabled(isJoined)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)

                    // Add event to device calendar
                    Button("Add to Calendar") {
                        addToCalendar()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Game Details")
        // Confirmation alert before leaving a game
        .alert("Leave Game?", isPresented: $showLeaveAlert) {
            Button("Leave", role: .destructive) {
                unjoinGame()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave this game?")
        }
        
        // Alert shown after successfully adding to calendar
        .alert("Saved to Calendar!", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    // Removes the user from the game and updates Firebase + UI
    func unjoinGame() {
        eventStore.leaveGame(event) { error in
            if let error = error {
                print("Leave failed:", error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                isJoined = false
                onStatusChange()
            }
        }
    }
    
    // Adds the user to the game and updates Firebase + UI
    func joinGame() {
        eventStore.joinGame(event) { error in
            if let error = error {
                print("Join failed:", error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                isJoined = true
                onStatusChange()
            }
        }
    }
    
    // Uses EventKit to save the game as a calendar event
    func addToCalendar() {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                let newEvent = EKEvent(eventStore: eventStore)

                newEvent.title = event.title
                newEvent.startDate = Date() // replace with real date later
                newEvent.endDate = Date().addingTimeInterval(60 * 60) // +1 hour
                newEvent.notes = event.locationName
                newEvent.calendar = eventStore.defaultCalendarForNewEvents

                do {
                    try eventStore.save(newEvent, span: .thisEvent)
                    DispatchQueue.main.async {
                        showSavedAlert = true
                    }
                } catch {
                    print("Error saving event")
                }
            }
        }
    }

}
