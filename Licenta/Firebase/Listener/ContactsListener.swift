//
//  ContactsListener.swift
//  Licenta
//
//  Created by Georgiana Costea on 24.05.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ContactsListener: ObservableObject {
    @Published var contacts: [ContactsModel] = []
    @Published var userStatuses: [String: String] = [:]
    private var listenerRegistration: ListenerRegistration? = nil
    private var statusListenerRegistration: ListenerRegistration? = nil

    func startListening() {
        stopListening()
        let currentUid = UserManager.shared.getCurrentUserID()
        
        listenerRegistration = FirebaseManager.shared.firestore.collection("contacts")
            .document(currentUid)
            .collection("my_contacts")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening for document changes: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    DispatchQueue.main.async {
                        self.contacts = []
                    }
                    return
                }
                
                Task {
                    var fetchedContacts: [ContactsModel] = []
                    
                    for document in documents {
                        let userData = document.data()
                        let userId = userData["user_id"] as? String ?? ""
                        
                        do {
                            if let user = try await UserManager.getUser(userId: userId) {
                                let contact = ContactsModel(
                                    userId: userId,
                                    profileImage: user.profile_image,
                                    user_name: user.user_name,
                                    token: user.token
                                )
                                fetchedContacts.append(contact)
                            }
                        } catch {
                            print("Error fetching user details for \(userId): \(error)")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.contacts = fetchedContacts
                        self.startStatusListener()
                    }
                }
            }
    }

    private func startStatusListener() {
        statusListenerRegistration = FirebaseManager.shared.firestore.collection("users_status")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                guard let documents = snapshot?.documents else {
                    print("No status documents found")
                    return
                }
                
                var statusDict: [String: String] = [:]
                for document in documents {
                    let userId = document.documentID
                    let status = document.data()["status"] as? String ?? "offline"
                    statusDict[userId] = status
                }
                
                DispatchQueue.main.async {
                    self.userStatuses = statusDict
                }
            }
    }

    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
        statusListenerRegistration?.remove()
        statusListenerRegistration = nil
    }
}



//class ContactsListener: ObservableObject {
//    @Published var contacts: [ContactsModel] = []
//    @Published var userStatuses: [String: String] = [:]
//    private var listenerRegistration: ListenerRegistration? = nil
//    private var statusListenerRegistration: ListenerRegistration? = nil
//    
//    func startListening() {
//        stopListening()
//        let currentUid = UserManager.shared.getCurrentUserID()
//        listenerRegistration = FirebaseManager.shared.firestore.collection("contacts")
//            .document(currentUid)
//            .collection("my_contacts")
//            .addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    print("Error listening for document changes: \(error)")
//                    return
//                }
//                guard let documents = querySnapshot?.documents else {
//                    print("No documents found")
//                    DispatchQueue.main.async {
//                        self.contacts = []
//                    }
//                    return
//                }
//                let fetchedContacts = documents.map { document in
//                    let userData = document.data()
//                    return ContactsModel(userId: userData["user_id"] as? String ?? "",
//                                         profileImage: userData["profile_picture"] as? String,
//                                         user_name: userData["name"] as? String ?? "",
//                                         token: userData["user_token"] as? String ?? ""
//                    )
//                }
//                .filter { contact in
//                    contact.userId != UserManager.shared.getCurrentUserID()
//                }
//                DispatchQueue.main.async {
//                    self.contacts = fetchedContacts
//                    self.startStatusListener()
//                }
//            }
//    }
//    
//    private func startStatusListener() {
//        statusListenerRegistration = FirebaseManager.shared.firestore.collection("users_status")
//            .addSnapshotListener { snapshot, error in
//                guard let documents = snapshot?.documents else {
//                    print("No status documents found")
//                    return
//                }
//                
//                var statusDict: [String: String] = [:]
//                for document in documents {
//                    let userId = document.documentID
//                    let status = document.data()["status"] as? String ?? "offline"
//                    statusDict[userId] = status
//                }
//                
//                DispatchQueue.main.async {
//                    self.userStatuses = statusDict
//                }
//            }
//    }
//    
//    func stopListening() {
//        listenerRegistration?.remove()
//        listenerRegistration = nil
//        statusListenerRegistration?.remove()
//        statusListenerRegistration = nil
//    }
//}
