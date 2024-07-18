//
//  UserManager.swift
//  Licenta
//
//  Created by Georgiana Costea on 15.04.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    func getCurrentUserID() -> String {
        if let currentUser = FirebaseManager.shared.auth.currentUser {
            return currentUser.uid
        } else {
            return ""
        }
    }
    
    static func getUser(userId: String) async throws -> UserModel? {
        do {
            let document = try await FirebaseManager.shared.firestore.collection("users").document(userId).getDocument()
            guard document.exists else {
                print("Document does not exist")
                return nil
            }
            guard let userData = document.data() else {
                print("No data found in document")
                return nil
            }
            let user = UserModel(
                user_id: document.documentID,
                profile_image: userData["profile_image"] as? String,
                email: userData["email"] as? String ?? "",
                user_name: userData["user_name"] as? String ?? "",
                createdAt: userData["date_created"]  as? Timestamp ?? Timestamp(),
                token: userData["user_token"] as? String ?? "")
            
            return user
        } catch {
            print("Error getting document: \(error)")
            throw error
        }
    }
    
    static func searchUsers(name: String) async throws -> [SearchModel] {
        let querySnapshot = try await FirebaseManager.shared.firestore.collection("users").whereField("user_name", isGreaterThanOrEqualTo: name)
            .whereField("user_name", isLessThanOrEqualTo: name + "z").getDocuments()
        var users: [SearchModel] = []
        for document in querySnapshot.documents {
            let userData = document.data()
            let user =  SearchModel(user_id: userData["user_id"] as? String ?? "",
                                    profile_image: userData["profile_image"] as? String,
                                    user_name: userData["user_name"] as? String ?? "", 
                                    user_token: userData["user_token"] as? String ?? "")
            if user.user_id != UserManager.shared.getCurrentUserID() {
                users.append(user)
            }
        }
        return users
    }
    
    static func saveNewContact(userId: String, name: String, profilePicture: String, userToken: String) {
        let newContact: [String:Any] = [
            "user_id": userId,
            "date_created": Timestamp(),
            "user_token": userToken
        ]
        let currentUser = UserManager.shared.getCurrentUserID()
        FirebaseManager.shared.firestore.collection("contacts").document(currentUser).collection("my_contacts").document(userId).setData(newContact, merge: false) { error in
            if let error = error {
                print("Error saving contact: \(error.localizedDescription)")
            } else {
                print("Contact saved successfully!")
            }
        }
    }
    
    func uploadImage(imageData: Data,  completion: @escaping (Result<URL, Error>) -> Void) {
        guard let userid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let path = "User/\(userid)/profilePhoto.jpg"
        let ref = FirebaseManager.shared.storage.reference().child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        ref.putData(imageData, metadata: metadata) { metadata, err in
            if let error = err {
                completion(.failure(error))
            } else {
                ref.downloadURL { url, err in
                    if let error = err {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    } else {
                        let unknownError = NSError(domain: "Unknown error", code: 0, userInfo: nil)
                        completion(.failure(unknownError))
                    }
                }
            }
        }
    }
    
    
    func editProfilePicture(newImage: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        uploadImage(imageData: newImage) { result in
            switch result {
            case .success(let downloadURL):
                print("Profile picture updated successfully! \(downloadURL.absoluteString)")
                self.updateUserProfilePictureURL(downloadURL) { result in
                    switch result {
                    case .success:
                        completion(.success(downloadURL))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    
    private func updateUserProfilePictureURL(_ url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData: [String: Any] = [
            "profile_image": url.absoluteString
        ]
        FirebaseManager.shared.firestore.collection("users").document(userId).setData(userData, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
     func changeUserName(newName: String) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("users").document(userId).setData(["user_name" : newName], merge: true) { err in
            if let error = err {
                print("Error updating new name: \(error.localizedDescription)")
            } else {
                print("New name updated successfully!")
            }
            self.updateNameInChats(newName: newName)
        }
    }
    
    func updateNameInChats(newName: String) {
        guard let currentUid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            
            let firestore = FirebaseManager.shared.firestore
            let chatsCollection = firestore.collection("chats")
            
            let firstUidQuery = chatsCollection.whereField("first_uid", isEqualTo: currentUid)
            firstUidQuery.getDocuments { firstUidQuerySnapshot, firstUidQueryError in
                if let firstUidQueryError = firstUidQueryError {
                    print("Error querying first_uid: \(firstUidQueryError.localizedDescription)")
                    return
                }
                
                guard let firstUidDocuments = firstUidQuerySnapshot?.documents else {
                    print("No documents found for first_uid query")
                    return
                }
                
                for document in firstUidDocuments {
                    var data = document.data()
                    data["first_name"] = newName
                    chatsCollection.document(document.documentID).setData(data, merge: true)
                }
                
                let secondUidQuery = chatsCollection.whereField("second_uid", isEqualTo: currentUid)
                secondUidQuery.getDocuments { secondUidQuerySnapshot, secondUidQueryError in
                    if let secondUidQueryError = secondUidQueryError {
                        print("Error querying second_uid: \(secondUidQueryError.localizedDescription)")
                        return
                    }
                    
                    guard let secondUidDocuments = secondUidQuerySnapshot?.documents else {
                        print("No documents found for second_uid query")
                        return
                    }
                    
                    for document in secondUidDocuments {
                        var data = document.data()
                        data["second_name"] = newName
                        chatsCollection.document(document.documentID).setData(data, merge: true)
                    }
                }
            }
        }
}
