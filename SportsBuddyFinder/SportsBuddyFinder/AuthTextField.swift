//
//  AuthTextField.swift
//  SportsBuddyFinder
//
//  Created by Daniel Loya on 4/19/26.
//

import SwiftUI

struct AuthTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        HStack {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
