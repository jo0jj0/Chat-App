//
//  AuthenticationManager.swift
//  Licenta
//
//  Created by Georgiana Costea on 11.04.2024.
//

import Foundation
import FirebaseAuth
import Firebase
import PhotosUI

struct AuthDataResultModel {
    let uid: String
    let name: String
    let email: String
    let profilePicture: String?
    
    init(user: UserInfo) {
        self.uid = user.uid
        self.name = user.displayName ?? ""
        self.email = user.email ?? ""
        self.profilePicture = user.photoURL?.absoluteString
    }
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    func authenticatedUser() throws -> AuthDataResultModel {
        guard let user = FirebaseManager.shared.auth.currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func registerUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                authResult.user.sendEmailVerification()
                completion(.success(authResult.user))
            }
        }
    }
    
    @discardableResult
    func logInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await FirebaseManager.shared.auth.signIn(withEmail: email, password: password)
        if !authDataResult.user.isEmailVerified {
            try await authDataResult.user.sendEmailVerification()
        }
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func passwordReset(email: String) async throws {
       try await FirebaseManager.shared.auth.sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = FirebaseManager.shared.auth.currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func logOut() throws{
       try FirebaseManager.shared.auth.signOut()
    }
    
    func reauthenticate(password: String) async throws -> Bool {
         guard let user = FirebaseManager.shared.auth.currentUser else {
             throw NSError(domain: "AuthenticationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
         }

         let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
         do {
             try await user.reauthenticate(with: credential)
             return true
         } catch {
             throw error
         }
     }

     func deleteAccount() async throws -> Bool {
         guard let user = FirebaseManager.shared.auth.currentUser else {
             throw NSError(domain: "AuthenticationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
         }

         let userId = user.uid
         let userDocRef = FirebaseManager.shared.firestore.collection("users").document(userId)
         let storageRef = FirebaseManager.shared.storage.reference().child("User/\(userId)/profilePhoto.jpg")
         let statusDocRef = FirebaseManager.shared.firestore.collection("users_status").document(userId)

         do {
             try await user.delete()
             try await userDocRef.delete()
             try await storageRef.delete()
             try await statusDocRef.setData(["status": "offline"])
             return true
         } catch {
             throw error
         }
     }
}
