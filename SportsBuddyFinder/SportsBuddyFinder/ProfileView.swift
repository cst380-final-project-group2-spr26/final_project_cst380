//
//  ProfileView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import UIKit

struct ProfileView: View {
    @Binding var isLoggedIn: Bool

    @State private var username = "Player"
    @State private var profileImageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var joinedGames: [SportsEvent] = []
    @State private var message = ""
    @State private var profileListener: ListenerRegistration?
    @State private var joinedGamesListener: ListenerRegistration?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    profileHeader

                    if !message.isEmpty {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }

                    joinedGamesSection

                    Button("Log Out") {
                        try? Auth.auth().signOut()
                        isLoggedIn = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .onAppear {
            startListening()
        }
        .onDisappear {
            stopListening()
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            updateProfileImage(from: newItem)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 14) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    profileImage
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )

                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .bold))
                        .padding(9)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }

            VStack(spacing: 4) {
                Text(username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Games Joined: \(joinedGames.count)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(.top, 24)
    }

    private var profileImage: some View {
        Group {
            if let profileImageData,
               let image = UIImage(data: profileImageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.15))
            }
        }
    }

    private var joinedGamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Joined Games")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if joinedGames.isEmpty {
                Text("You have not joined any games yet.")
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.14))
                    .cornerRadius(14)
            } else {
                ForEach(joinedGames) { game in
                    joinedGameCard(for: game)
                }
            }
        }
    }

    private func joinedGameCard(for game: SportsEvent) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(game.title)
                    .font(.headline)

                Spacer()

                Text(game.sport)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.16))
                    .cornerRadius(10)
            }

            Text("You joined a \(game.skillLevel.lowercased()) \(game.sport.lowercased()) game at \(game.locationName).")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Label(game.time, systemImage: "clock")
                .font(.caption)
                .foregroundColor(.secondary)

            Label(game.locationName, systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    private func startListening() {
        listenToProfile()
        listenToJoinedGames()
    }

    private func stopListening() {
        profileListener?.remove()
        joinedGamesListener?.remove()
        profileListener = nil
        joinedGamesListener = nil
    }

    private func listenToProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        profileListener?.remove()
        profileListener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        message = error.localizedDescription
                    }
                    return
                }

                let data = snapshot?.data()
                DispatchQueue.main.async {
                    username = data?["username"] as? String ?? Auth.auth().currentUser?.email ?? "Player"

                    if let imageString = data?["profileImageData"] as? String,
                       let data = Data(base64Encoded: imageString) {
                        profileImageData = data
                    }
                }
            }
    }

    private func listenToJoinedGames() {
        joinedGamesListener?.remove()
        joinedGamesListener = GameService.shared.listenToJoinedGames { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    joinedGames = games
                    if !message.contains("profile picture") {
                        message = ""
                    }
                case .failure(let error):
                    message = error.localizedDescription
                }
            }
        }
    }

    private func updateProfileImage(from item: PhotosPickerItem?) {
        guard let item else {
            return
        }

        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data),
                      let jpegData = compressedProfileImageData(from: image) else {
                    return
                }

                await saveProfileImageData(jpegData)
            } catch {
                await MainActor.run {
                    message = error.localizedDescription
                }
            }
        }
    }

    @MainActor
    private func saveProfileImageData(_ data: Data) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        profileImageData = data
        message = "Saving profile picture..."

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData([
                    "profileImageData": data.base64EncodedString(),
                    "updatedAt": Timestamp(date: Date())
                ], merge: true)

            message = ""
        } catch {
            message = error.localizedDescription
        }
    }

    private func compressedProfileImageData(from image: UIImage) -> Data? {
        let maxLength: CGFloat = 500
        let scale = min(maxLength / image.size.width, maxLength / image.size.height, 1)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

        return resizedImage.jpegData(compressionQuality: 0.65)
    }
}
