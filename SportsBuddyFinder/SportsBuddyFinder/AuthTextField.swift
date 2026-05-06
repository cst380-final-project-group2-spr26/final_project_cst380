//
//  AuthTextField.swift
//  SportsBuddyFinder
//
//  Created by Daniel Loya on 4/19/26.
//

import SwiftUI

// Reusable text input field for authentication screens (login/signup).
// Supports both regular and secure (password) input.
struct AuthTextField: View {
    
    //Placeholder text displayed inside the field
    let placeholder: String
    // Bound text value entered by the user
    @Binding var text: String
    
    // Determines whether the field is secure (password input)
    var isSecure: Bool = false

    var body: some View {
        Group {
            // Use SecureField if this is a password field
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                // Otherwise, use a standard text field
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
