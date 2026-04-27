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

    private func event(from document: QueryDocumentSnapshot) -> SportsEvent {
        event(id: document.documentID, data: document.data())
    }

    private func event(id: String, data: [String: Any]) -> SportsEvent {
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
            id: id,
            title: title,
            sport: sport,
            time: formattedDate,
            locationName: locationName,
            skillLevel: skillLevel,
            spotsLeft: spotsLeft,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            hostUid: data["hostUid"] as? String
        )
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

                let events = snapshot?.documents.map { self.event(from: $0) } ?? []

                completion(.success(events))
            }
    }

    func fetchJoinedGameIDs(completion: @escaping (Result<Set<String>, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return
        }

        usersCollection
            .document(uid)
            .collection("joinedGames")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let joinedGameIDs = Set(snapshot?.documents.map(\.documentID) ?? [])
                completion(.success(joinedGameIDs))
            }
    }

    func joinGame(event: SportsEvent, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "GameService", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "No logged in user."
            ]))
            return
        }

        if event.hostUid == uid {
            completion(NSError(domain: "GameService", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "You already host this game."
            ]))
            return
        }

        let gameRef = db.collection("games").document(event.id)
        let attendeeRef = gameRef.collection("attendees").document(uid)
        let joinedGameRef = usersCollection.document(uid).collection("joinedGames").document(event.id)

        db.runTransaction({ transaction, errorPointer in
            let snapshot: DocumentSnapshot

            do {
                snapshot = try transaction.getDocument(gameRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            if snapshot.data() == nil {
                errorPointer?.pointee = NSError(domain: "GameService", code: 3, userInfo: [
                    NSLocalizedDescriptionKey: "This game no longer exists."
                ])
                return nil
            }

            if let attendeeSnapshot = try? transaction.getDocument(attendeeRef),
               attendeeSnapshot.exists {
                return nil
            }

            let spotsLeft = snapshot.data()?["spotsLeft"] as? Int ?? 0
            if spotsLeft <= 0 {
                errorPointer?.pointee = NSError(domain: "GameService", code: 4, userInfo: [
                    NSLocalizedDescriptionKey: "This game is already full."
                ])
                return nil
            }

            transaction.updateData([
                "spotsLeft": spotsLeft - 1
            ], forDocument: gameRef)

            transaction.setData([
                "joinedAt": Timestamp(date: Date())
            ], forDocument: attendeeRef)

            transaction.setData([
                "joinedAt": Timestamp(date: Date()),
                "gameTitle": event.title,
                "sport": event.sport
            ], forDocument: joinedGameRef)

            return nil
        }) { _, error in
            completion(error)
        }
    }

    func listenToJoinedGames(completion: @escaping (Result<[SportsEvent], Error>) -> Void) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return nil
        }

        return usersCollection
            .document(uid)
            .collection("joinedGames")
            .order(by: "joinedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let joinedDocuments = snapshot?.documents ?? []

                guard !joinedDocuments.isEmpty else {
                    completion(.success([]))
                    return
                }

                var eventsByID: [String: SportsEvent] = [:]
                var firstError: Error?
                let resultsQueue = DispatchQueue(label: "GameService.joinedGamesResults")
                let group = DispatchGroup()

                for joinedDocument in joinedDocuments {
                    group.enter()

                    self.db.collection("games").document(joinedDocument.documentID).getDocument { gameSnapshot, error in
                        resultsQueue.async {
                            defer { group.leave() }

                            if let error = error {
                                firstError = firstError ?? error
                                return
                            }

                            guard let gameSnapshot,
                                  let data = gameSnapshot.data() else {
                                return
                            }

                            eventsByID[joinedDocument.documentID] = self.event(id: gameSnapshot.documentID, data: data)
                        }
                    }
                }

                group.notify(queue: .main) {
                    if let firstError {
                        completion(.failure(firstError))
                        return
                    }

                    let events = joinedDocuments.compactMap { eventsByID[$0.documentID] }
                    completion(.success(events))
                }
            }
    }
}
