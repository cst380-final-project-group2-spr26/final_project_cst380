//
//  GameDetailView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/25/26.
//

import SwiftUI
import EventKit

struct GameDetailView: View {
    let event: SportsEvent
    @Binding var isJoined: Bool
    let onStatusChange: () -> Void

    @State private var showSavedAlert = false
    @State private var showLeaveAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                VStack(spacing: 6) {
                    Text(event.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(event.sport)
                        .foregroundColor(.orange)
                        .font(.title3)
                }

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

                VStack(spacing: 12) {

                    Button {
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
        .alert("Leave Game?", isPresented: $showLeaveAlert) {
            Button("Leave", role: .destructive) {
                unjoinGame()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave this game?")
        }
        
        .alert("Saved to Calendar!", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    func unjoinGame() {
        GameService.shared.leaveGame(event: event) { error in
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
    
    func joinGame() {
        GameService.shared.joinGame(event: event) { error in
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
