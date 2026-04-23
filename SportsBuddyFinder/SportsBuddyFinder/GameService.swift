//
//  GameService.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/22/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

final class GameService {
    static let shared = GameService()

    private let db = Firestore.firestore()

    private init() {}

    func createGame(
        sport: String,
        gameDate: Date,
        locationName: String,
        latitude: Double,
        longitude: Double,
        completion: @escaping (Error?) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "GameService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "No logged in user."
            ]))
            return
        }

        let title = "\(sport) Game"

        let data: [String: Any] = [
            "title": title,
            "sport": sport,
            "gameDate": Timestamp(date: gameDate),
            "locationName": locationName,
            "skillLevel": "All Levels",
            "spotsLeft": 10,
            "latitude": latitude,
            "longitude": longitude,
            "hostUid": uid,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("games").addDocument(data: data, completion: completion)
    }

    func fetchGames(completion: @escaping (Result<[SportsEvent], Error>) -> Void) {
        db.collection("games")
            .order(by: "gameDate", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let events: [SportsEvent] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()

                    let title = data["title"] as? String ?? "Untitled Game"
                    let sport = data["sport"] as? String ?? "Unknown Sport"
                    let locationName = data["locationName"] as? String ?? "Unknown Location"
                    let skillLevel = data["skillLevel"] as? String ?? "All Levels"
                    let spotsLeft = data["spotsLeft"] as? Int ?? 0
                    let latitude = data["latitude"] as? Double ?? 36.6522
                    let longitude = data["longitude"] as? Double ?? -121.7989

                    let timestamp = data["gameDate"] as? Timestamp ?? Timestamp(date: Date())
                    let date = timestamp.dateValue()

                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    let formattedDate = formatter.string(from: date)

                    return SportsEvent(
                        id: doc.documentID,
                        title: title,
                        sport: sport,
                        time: formattedDate,
                        locationName: locationName,
                        skillLevel: skillLevel,
                        spotsLeft: spotsLeft,
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    )
                } ?? []

                completion(.success(events))
            }
    }
}
