//
//  UserCredentials.swift
//  Licenta
//
//  Created by Georgiana Costea on 19.06.2024.
//

import Foundation
import StreamVideo
import StreamChat

// Function to add the user to Stream Chat
struct UserCredentials {
    static func addUserToGetStream(userId: String, token: String) {
        do {
            // Print the token to ensure it's correct
            print("Attempting to create token with: \(token)")

            // Create the token
            let userToken = try Token(rawValue: token)
            
            // Print success message
            print("Token created successfully")
            
            // Connect the user to Stream Chat
            ChatClient.shared.connectUser(
                userInfo: .init(id: userId), // Provide only the user ID
                token: userToken
            ) { error in
                if let error = error {
                    print("Connection failed with: \(error.localizedDescription)")
                } else {
                    // User successfully connected
                    print("User successfully connected")
                }
            }
        } catch {
            print("Token initialization failed with error: \(error.localizedDescription)")
        }
    }
}
