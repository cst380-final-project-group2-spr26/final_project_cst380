//
//  CreateView.swift
//  SportsBuddyFinder
//
//  Created by Krishneet on 4/19/26.
//

import SwiftUI

struct CreateView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 15) {
                Text("Create Game")
                    .font(.title)
                    .foregroundColor(.white)

                AuthTextField(placeholder: "Sport", text: .constant(""))
                AuthTextField(placeholder: "Time", text: .constant(""))
                AuthTextField(placeholder: "Location", text: .constant(""))

                Button("Create Game") {}
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
    }
}
