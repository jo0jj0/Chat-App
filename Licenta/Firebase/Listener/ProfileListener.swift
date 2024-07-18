//
//  ProfileListener.swift
//  Licenta
//
//  Created by Georgiana Costea on 13.06.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfileListener: ObservableObject {
    @Published var user: UserModel? = nil
    private var listenerRegistration: ListenerRegistration? = nil
    
    func startListening() {
        stopListening()
        let currentUid = UserManager.shared.getCurrentUserID()
        listenerRegistration = FirebaseManager.shared.firestore
            .collection("users")
            .document(currentUid)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error listening for document changes: \(error)")
                    return
                }
                guard let document = documentSnapshot, document.exists, let userData = document.data() else {
                    print("Document does not exist or no data found")
                    DispatchQueue.main.async {
                        self.user = nil
                    }
                    return
                }
                let user = UserModel(
                    user_id: document.documentID,
                    profile_image: userData["profile_image"] as? String,
                    email: userData["email"] as? String ?? "",
                    user_name: userData["user_name"] as? String ?? "",
                    createdAt: userData["date_created"]  as? Timestamp ?? Timestamp(),
                    token: userData["user_token"] as? String ?? ""
                )
                DispatchQueue.main.async {
                    self.user = user
                }
            }
    }
    
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
}
