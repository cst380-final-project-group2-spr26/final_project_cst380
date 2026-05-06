//
//  SportsEvent.swift
//  SportsBuddyFinder
//
//  Created by Abel Plascencia on 4/19/26.
//

import Foundation
import MapKit

// Represents a sports game/event in the app.
// Used for displaying and managing game data across views.
struct SportsEvent: Identifiable, Equatable {
    // Unique identifier for the event (from Firestore)
    let id: String
    
    // Title of the game
    let title: String
    
    // Type of sport (e.g., Basketball, Soccer)
    let sport: String
    
    // Formatted date and time string
    let time: String
    
    // Name of the event location
    let locationName: String
    
    // Skill level of the game (e.g., Beginner, Intermediate)
    let skillLevel: String
    
    // Number of spots remaining for the event
    let spotsLeft: Int
    
    // Geographic coordinate used for MapKit display
    let coordinate: CLLocationCoordinate2D
    
    // ID of the user who created the event
    let hostUid: String?

    // Determines equality based on unique event ID
    static func == (lhs: SportsEvent, rhs: SportsEvent) -> Bool {
        lhs.id == rhs.id
    }
}

extension SportsEvent {
    // Sample events used for testing and previews
    static let sampleEvents: [SportsEvent] = [
        SportsEvent(
            id: UUID().uuidString,
            title: "Open Gym Hoops",
            sport: "Basketball",
            time: "Today · 6:00 PM",
            locationName: "Otter Sports Center",
            skillLevel: "Intermediate",
            spotsLeft: 4,
            coordinate: CLLocationCoordinate2D(latitude: 36.6525, longitude: -121.7978),
            hostUid: nil
        ),
        SportsEvent(
            id: UUID().uuidString,
            title: "Sunset Soccer Run",
            sport: "Soccer",
            time: "Today · 7:15 PM",
            locationName: "CSUMB Recreation Field",
            skillLevel: "Beginner Friendly",
            spotsLeft: 9,
            coordinate: CLLocationCoordinate2D(latitude: 36.6509, longitude: -121.8012),
            hostUid: nil
        ),
        SportsEvent(
            id: UUID().uuidString,
            title: "Morning Tennis Rally",
            sport: "Tennis",
            time: "Tomorrow · 9:00 AM",
            locationName: "CSUMB Tennis Courts",
            skillLevel: "All Levels",
            spotsLeft: 2,
            coordinate: CLLocationCoordinate2D(latitude: 36.6534, longitude: -121.8001),
            hostUid: nil
        ),
        SportsEvent(
            id: UUID().uuidString,
            title: "Flag Football Meetup",
            sport: "Football",
            time: "Saturday · 11:30 AM",
            locationName: "Main Athletic Field",
            skillLevel: "Casual",
            spotsLeft: 12,
            coordinate: CLLocationCoordinate2D(latitude: 36.6516, longitude: -121.8030),
            hostUid: nil
        )
    ]
}
