//
//  ListView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth

struct ListView: View {
    @EnvironmentObject private var eventStore: EventStore
    @State private var joiningGameIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Available Games")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)

                        if !eventStore.message.isEmpty {
                            Text(eventStore.message)
                                .foregroundColor(.white)
                                .font(.caption)
                        }

                        if eventStore.events.isEmpty {
                            Text("No games available yet.")
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.top, 40)
                        } else {
//
//  GameService.swift
//  SportsBuddyFinder
//
//  Created by Felipe Lopez on 4/22/26.
//

import Foundation
import SwiftUI
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

    private func appError(_ message: String, code: Int = 0) -> Error {
        NSError(domain: "GameService", code: code, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
    }

    private func mapFirestoreError(_ error: Error, fallback: String) -> Error {
        let nsError = error as NSError

        if nsError.domain == FirestoreErrorDomain,
           nsError.code == FirestoreErrorCode.permissionDenied.rawValue {
            return appError(
                "Firestore denied this action. Update your Firestore rules to allow signed-in users to create and join games.",
                code: nsError.code
            )
        }

        let message = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return appError(message.isEmpty ? fallback : message, code: nsError.code)
    }

    func observeGames(onChange: @escaping (Result<[SportsEvent], Error>) -> Void) -> ListenerRegistration {
        db.collection("games")
            .order(by: "gameDate", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onChange(.failure(self.mapFirestoreError(error, fallback: "Unable to load games.")))
                    return
                }

                let events = snapshot?.documents.map(self.makeSportsEvent(from:)) ?? []
                onChange(.success(events))
            }
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

        db.collection("games").addDocument(data: data) { error in
            if let error {
                completion(self.mapFirestoreError(error, fallback: "Unable to create game."))
                return
            }

            completion(nil)
        }
    }

    func fetchGames(completion: @escaping (Result<[SportsEvent], Error>) -> Void) {
        db.collection("games")
            .order(by: "gameDate", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(self.mapFirestoreError(error, fallback: "Unable to load games.")))
                    return
                }

                let events = snapshot?.documents.map(self.makeSportsEvent(from:)) ?? []

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

    let gameRef = db.collection("games").document(event.id)
    let attendeeRef = gameRef.collection("attendees").document(uid)

    db.runTransaction { transaction, errorPointer in
        let gameDoc: DocumentSnapshot
        do {
            gameDoc = try transaction.getDocument(gameRef)
        } catch {
            return nil
        }

        let currentSpots = gameDoc.data()?["spotsLeft"] as? Int ?? 0

        // Remove attendee
        transaction.deleteDocument(attendeeRef)

        // Increase spots
        transaction.updateData([
            "spotsLeft": currentSpots + 1
        ], forDocument: gameRef)

        return nil
    } completion: { _, error in
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
        }) { _, error in
            if let error {
                completion(self.mapFirestoreError(error, fallback: "Unable to join this game."))
                return
            }

            completion(nil)
        }
    }

    private func makeSportsEvent(from doc: QueryDocumentSnapshot) -> SportsEvent {
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

        return SportsEvent(
            id: doc.documentID,
            title: title,
            sport: sport,
            time: formatter.string(from: date),
            locationName: locationName,
            skillLevel: skillLevel,
            spotsLeft: spotsLeft,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            hostUid: data["hostUid"] as? String
        )
    }
}

@MainActor
final class EventStore: ObservableObject {
    @Published var events: [SportsEvent] = []
    @Published var joinedGameIDs: Set<String> = []
    @Published var message = ""

    private let gameService: GameService
    private var gamesListener: ListenerRegistration?

    init(gameService: GameService = .shared) {
        self.gameService = gameService
        start()
    }

    deinit {
        gamesListener?.remove()
    }

    func start() {
        if gamesListener == nil {
            gamesListener = gameService.observeGames { [weak self] result in
                Task { @MainActor in
                    switch result {
                    case .success(let events):
                        self?.events = events
                        if self?.message.contains("join") != true {
                            self?.message = ""
                        }
                    case .failure(let error):
                        self?.message = error.localizedDescription
                    }
                }
            }
        }

        refreshJoinedGameIDs()
    }

    func refreshJoinedGameIDs() {
        gameService.fetchJoinedGameIDs { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let ids):
                    self?.joinedGameIDs = ids
                case .failure(let error):
                    self?.message = error.localizedDescription
                }
            }
        }
    }

    func joinGame(_ event: SportsEvent, completion: ((Error?) -> Void)? = nil) {
        gameService.joinGame(event: event) { [weak self] error in
            Task { @MainActor in
                if let error {
                    self?.message = error.localizedDescription
                    completion?(error)
                    return
                }

                self?.joinedGameIDs.insert(event.id)
                self?.events = self?.events.map { currentEvent in
                    guard currentEvent.id == event.id else {
                        return currentEvent
                    }

                    return SportsEvent(
                        id: currentEvent.id,
                        title: currentEvent.title,
                        sport: currentEvent.sport,
                        time: currentEvent.time,
                        locationName: currentEvent.locationName,
                        skillLevel: currentEvent.skillLevel,
                        spotsLeft: max(currentEvent.spotsLeft - 1, 0),
                        coordinate: currentEvent.coordinate,
                        hostUid: currentEvent.hostUid
                    )
                } ?? []
                self?.message = "You joined \(event.title)."
                self?.refreshJoinedGameIDs()
                completion?(nil)
            }
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
                            ForEach(eventStore.events) { event in
                                eventRow(for: event)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                eventStore.start()
            }
            .onChange(of: joinedGameIDs) { _ in
                loadGames()
            }
            .refreshable {
                eventStore.start()
            }
        }
    }

    private func eventRow(for event: SportsEvent) -> some View {
        let currentUid = Auth.auth().currentUser?.uid
        let isHost = event.hostUid == currentUid
        let isJoined = eventStore.joinedGameIDs.contains(event.id)
        let isJoining = joiningGameIDs.contains(event.id)
        let canJoin = !isHost && !isJoined && !isJoining && event.spotsLeft > 0

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(event.title)
                    .font(.headline)

                Spacer()

                Text(event.sport)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
            }

            Label(event.time, systemImage: "clock")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Label(event.locationName, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(event.skillLevel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(8)

                Spacer()

                Text("\(event.spotsLeft) spots left")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button {
                joinGame(event)
            } label: {
                Text(joinButtonTitle(isHost: isHost, isJoined: isJoined, isJoining: isJoining, spotsLeft: event.spotsLeft))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(canJoin ? Color.green : Color.gray.opacity(0.35))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!canJoin)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func joinButtonTitle(isHost: Bool, isJoined: Bool, isJoining: Bool, spotsLeft: Int) -> String {
        if isHost {
            return "You Created This Game"
        }

        if isJoined {
            return "Joined"
        }

        if isJoining {
            return "Joining..."
        }

        if spotsLeft <= 0 {
            return "Game Full"
        }

        return "Join Game"
    }

    private func joinGame(_ event: SportsEvent) {
        joiningGameIDs.insert(event.id)

        eventStore.message = ""
        eventStore.joinGame(event) { error in
            joiningGameIDs.remove(event.id)
            if let error {
                eventStore.message = error.localizedDescription
            }
        }
    }
}

#Preview {
    ListView()
        .environmentObject(EventStore())
}
