//
//  HiddenChatListListener.swift
//  Licenta
//
//  Created by Georgiana Costea on 22.06.2024.
//

import Foundation
import Firebase

class HiddenChatListListener: ObservableObject {
    @Published var chats: [ChatModel] = []
    @Published var userStatuses: [String: String] = [:]
    private var listenerRegistration: ListenerRegistration? = nil
    private var statusListenerRegistration: ListenerRegistration? = nil
    
    func fetchChats() {
        stopListening()
        
        let currentUid = UserManager.shared.getCurrentUserID()
        
        listenerRegistration = FirebaseManager.shared.firestore.collection("chats")
            .whereFilter(
                Filter.orFilter(
                    [
                        Filter.whereField("first_hidden_id", isEqualTo: currentUid),
                        Filter.whereField("second_hidden_id", isEqualTo: currentUid)
                    ]
                )
            )
            .order(by: "last_message_time", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error retrieving documents: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    DispatchQueue.main.async {
                        self.chats = []
                    }
                    return
                }
                let fetchedChats = documents.map { document in
                    let data = document.data()
                    return ChatModel(
                        id: data["id"] as? String ?? "",
                        firstUid: data["first_uid"] as? String ?? "",
                        secondUid: data["second_uid"] as? String ?? "",
                        firstName: data["first_name"] as? String ?? "",
                        secondName: data["second_name"] as? String ?? "",
                        firstProfilePicture: data["first_profile_picture"] as? String ?? "",
                        secondProfilePicture: data["second_profile_picture"] as? String ?? "",
                        lastMessage: data["last_message"] as? String ?? "",
                        lastMessageTime: data["last_message_time"] as? Timestamp ?? Timestamp(),
                        isLastMessageRead: data["is_last_message_read"] as? Bool ?? true,
                        lastMessageReceiverUid: data["last_message_receiver_uid"] as? String ?? "",
                        isPhoto: data["is_photo"] as? Bool ?? false,
                        isAudio: data["is_audio"] as? Bool ?? false,
                        callId: data["call_id"] as? String ?? "",
                        firstToken: data["first_token"] as? String ?? "",
                        secondToken: data["second_token"] as? String ?? "",
                        firstDeleteId: data["first_delete_id"] as? String ?? "",
                        secondDeleteId: data["second_delete_id"] as? String ?? "",
                        firstHiddenId: data["first_hidden_id"] as? String ?? "",
                        secondHiddenId: data["second_hidden_id"] as? String ?? "",
                        key: data["key"] as? String ?? ""
                    )
                }
                
                DispatchQueue.main.async {
                    self.chats = fetchedChats
                    self.startStatusListener()
                }
            }
    }
    
    private func startStatusListener() {
        statusListenerRegistration = FirebaseManager.shared.firestore.collection("users_status")
            .addSnapshotListener { snapshot, error in
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
