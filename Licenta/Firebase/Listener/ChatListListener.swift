//
//  ChatListListener.swift
//  Licenta
//
//  Created by Georgiana Costea on 19.05.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


class ChatListListener: ObservableObject {
    @Published var chats: [ChatModel] = []
    @Published var userStatuses: [String: String] = [:]
    private var listenerRegistration: ListenerRegistration? = nil
    private var statusListenerRegistration: ListenerRegistration? = nil
    
    func startListening() {
            stopListening()
            
            let currentUid = UserManager.shared.getCurrentUserID()
            
            listenerRegistration = FirebaseManager.shared.firestore.collection("chats")
                .whereFilter(
                    Filter.orFilter(
                        [
                            Filter.whereField("first_uid", isEqualTo: currentUid),
                            Filter.whereField("second_uid", isEqualTo: currentUid)
                        ]
                    )
                )
                .order(by: "last_message_time", descending: true)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Error listening for document changes: \(error)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found")
                        DispatchQueue.main.async {
                            self.chats = []
                        }
                        return
                    }
                    
                    Task {
                        do {
                            let tempFetchedChats = try await self.fetchAllChats(documents: documents, currentUid: currentUid)
                            DispatchQueue.main.async {
                                self.chats = tempFetchedChats
                                self.startStatusListener()
                            }
                        } catch {
                            print("Error fetching chat details: \(error)")
                        }
                    }
                }
        }
        
        private func fetchAllChats(documents: [QueryDocumentSnapshot], currentUid: String) async throws -> [ChatModel] {
            var tempFetchedChats: [ChatModel] = []
            
            for document in documents {
                let data = document.data()
                let chatId = data["id"] as? String ?? ""

                async let lastMessageEncrypted = MessageManager.shared.getLastValidMessage(chatId: chatId, currentUserId: currentUid)
                async let lastMessageTimestamp = MessageManager.shared.getLastValidTimestamp(chatId: chatId, currentUserId: currentUid)
                async let key = MessageManager.shared.fetchKey(chatId: chatId)

                do {
                    let (encryptedMessage, timestamp, key) = try await (lastMessageEncrypted, lastMessageTimestamp, key)
                    let lastMessage = try aesDecrypt(encryptedMessage: encryptedMessage, key: key)
                    
                    let chat = ChatModel(
                        id: chatId,
                        firstUid: data["first_uid"] as? String ?? "",
                        secondUid: data["second_uid"] as? String ?? "",
                        firstName: data["first_name"] as? String ?? "",
                        secondName: data["second_name"] as? String ?? "",
                        firstProfilePicture: data["first_profile_picture"] as? String ?? "",
                        secondProfilePicture: data["second_profile_picture"] as? String ?? "",
                        lastMessage: lastMessage,
                        lastMessageTime: timestamp,
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
                    
                    tempFetchedChats.append(chat)
                } catch {
                    print("Error processing chat document: \(error)")
                }
            }
            
            return tempFetchedChats
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
