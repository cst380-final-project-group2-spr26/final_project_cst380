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

    private var usersCollection: CollectionReference {
        db.collection("users")
    }

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
            "maxPlayers": 10,
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
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        hostUid: data["hostUid"] as? String
                    )
                } ?? []

                completion(.success(events))
            }
    }

//    func fetchJoinedGameIDs(completion: @escaping (Result<Set<String>, Error>) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion(.success([]))
//            return
//        }
//
//        usersCollection
//            .document(uid)
//            .collection("joinedGames")
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                let joinedGameIDs = Set(snapshot?.documents.map(\.documentID) ?? [])
//                completion(.success(joinedGameIDs))
//            }
//    }

//    func joinGame(event: SportsEvent, completion: @escaping (Error?) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion(NSError(domain: "GameService", code: 1, userInfo: [
//                NSLocalizedDescriptionKey: "No logged in user."
//            ]))
//            return
//        }
//
//        if event.hostUid == uid {
//            completion(NSError(domain: "GameService", code: 2, userInfo: [
//                NSLocalizedDescriptionKey: "You already host this game."
//            ]))
//            return
//        }
//
//        let gameRef = db.collection("games").document(event.id)
//        let attendeeRef = gameRef.collection("attendees").document(uid)
//        let joinedGameRef = usersCollection.document(uid).collection("joinedGames").document(event.id)
//
//        db.runTransaction({ transaction, errorPointer in
//            let snapshot: DocumentSnapshot
//
//            do {
//                snapshot = try transaction.getDocument(gameRef)
//            } catch {
//                errorPointer?.pointee = error as NSError
//                return nil
//            }
//
//            if snapshot.data() == nil {
//                errorPointer?.pointee = NSError(domain: "GameService", code: 3, userInfo: [
//                    NSLocalizedDescriptionKey: "This game no longer exists."
//                ])
//                return nil
//            }
//
//            if let attendeeSnapshot = try? transaction.getDocument(attendeeRef),
//               attendeeSnapshot.exists {
//                return nil
//            }
//
//            let spotsLeft = snapshot.data()?["spotsLeft"] as? Int ?? 0
//            if spotsLeft <= 0 {
//                errorPointer?.pointee = NSError(domain: "GameService", code: 4, userInfo: [
//                    NSLocalizedDescriptionKey: "This game is already full."
//                ])
//                return nil
//            }
//
//            transaction.updateData([
//                "spotsLeft": spotsLeft - 1
//            ], forDocument: gameRef)
//
//            transaction.setData([
//                "joinedAt": Timestamp(date: Date())
//            ], forDocument: attendeeRef)
//
//            transaction.setData([
//                "joinedAt": Timestamp(date: Date()),
//                "gameTitle": event.title,
//                "sport": event.sport
//            ], forDocument: joinedGameRef)
//
//            return nil
//        }) { _, error in
//            completion(error)
//        }
//    }
    
    func leaveGame(event: SportsEvent, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let gameRef = db.collection("games").document(event.id)

        let attendeeRef = gameRef
            .collection("attendees")
            .document(uid)

        db.runTransaction { transaction, errorPointer in
            let gameDoc: DocumentSnapshot
            do {
                gameDoc = try transaction.getDocument(gameRef)
            } catch {
                return nil
            }

            let currentSpots = gameDoc.data()?["spotsLeft"] as? Int ?? 0

            // 1. Delete attendee
            transaction.deleteDocument(attendeeRef)

            // 2. Increase spots
            transaction.updateData([
                "spotsLeft": currentSpots + 1
            ], forDocument: gameRef)

            return nil

        } completion: { _, error in
            if let error = error {
                print("Transaction failed:", error.localizedDescription)
            } else {
                print("Leave successful")
            }
            completion(error)
        }
    }
    
    func joinGame(event: SportsEvent, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let gameRef = db.collection("games").document(event.id)

        let attendeeRef = gameRef
            .collection("attendees")
            .document(uid)

        db.runTransaction { transaction, errorPointer in
            let gameDoc: DocumentSnapshot
            do {
                gameDoc = try transaction.getDocument(gameRef)
            } catch {
                return nil
            }

            let currentSpots = gameDoc.data()?["spotsLeft"] as? Int ?? 0

            if currentSpots <= 0 {
                return nil
            }

            // Add attendee
            transaction.setData([
                "joinedAt": Timestamp()
            ], forDocument: attendeeRef)

            // Decrease spots
            transaction.updateData([
                "spotsLeft": currentSpots - 1
            ], forDocument: gameRef)

            return nil

        } completion: { _, error in
            completion(error)
        }
    }
    
    func fetchJoinedGameIDs(completion: @escaping (Result<Set<String>, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        db.collection("games").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            var joinedIDs: Set<String> = []

            let group = DispatchGroup()

            snapshot?.documents.forEach { doc in
                group.enter()

                db.collection("games")
                    .document(doc.documentID)
                    .collection("attendees")
                    .document(uid)
                    .getDocument { attendeeDoc, _ in

                        if attendeeDoc?.exists == true {
                            joinedIDs.insert(doc.documentID)
                        }

                        group.leave()
                    }
            }

            group.notify(queue: .main) {
                completion(.success(joinedIDs))
            }
        }
    }
}
