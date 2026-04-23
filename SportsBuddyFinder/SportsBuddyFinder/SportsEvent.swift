//
//  SportsEvent.swift
//  SportsBuddyFinder
//
//  Created by Abel Plascencia on 4/19/26.
//

import Foundation
import MapKit

struct SportsEvent: Identifiable, Equatable {
    let id: String
    let title: String
    let sport: String
    let time: String
    let locationName: String
    let skillLevel: String
    let spotsLeft: Int
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: SportsEvent, rhs: SportsEvent) -> Bool {
        lhs.id == rhs.id
    }
}

extension SportsEvent {
    static let sampleEvents: [SportsEvent] = [
        SportsEvent(
            id: UUID().uuidString,
            title: "Open Gym Hoops",
            sport: "Basketball",
            time: "Today · 6:00 PM",
            locationName: "Otter Sports Center",
            skillLevel: "Intermediate",
            spotsLeft: 4,
            coordinate: CLLocationCoordinate2D(latitude: 36.6525, longitude: -121.7978)
        ),
        SportsEvent(
            id: UUID().uuidString,
            title: "Sunset Soccer Run",
            sport: "Soccer",
            time: "Today · 7:15 PM",
            locationName: "CSUMB Recreation Field",
            skillLevel: "Beginner Friendly",
            spotsLeft: 9,
            coordinate: CLLocationCoordinate2D(latitude: 36.6509, longitude: -121.8012)
        ),
        SportsEvent(
            id: UUID().uuidString,
            title: "Morning Tennis Rally",
            sport: "Tennis",
            time: "Tomorrow · 9:00 AM",
            locationName: "CSUMB Tennis Courts",
            skillLevel: "All Levels",
            spotsLeft: 2,
            coordinate: CLLocationCoordinate2D(latitude: 36.6534, longitude: -121.8001)
        ),
        SportsEvent(
            id: UUID().uuidString,
            title: "Flag Football Meetup",
            sport: "Football",
            time: "Saturday · 11:30 AM",
            locationName: "Main Athletic Field",
            skillLevel: "Casual",
            spotsLeft: 12,
            coordinate: CLLocationCoordinate2D(latitude: 36.6516, longitude: -121.8030)
        )
    ]
}
