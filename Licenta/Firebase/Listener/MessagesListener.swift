//
//  MessagesListener.swift
//  Licenta
//
//  Created by Georgiana Costea on 19.05.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessagesListener: ObservableObject {
    @Published var messages: [MessageModel] = []
    @Published var userStatuses: [String: String] = [:]
    @Published var isLastMessageRead: Bool = true
    @Published var videoCallExists: Bool = false
    @Published var audioCallExists: Bool = false
    @Published var isVidoCall: Bool = false
    
    private var listenerRegistration: ListenerRegistration? = nil
    private var chatListenerRegistration: ListenerRegistration? = nil
    private var statusListenerRegistration: ListenerRegistration? = nil
    private var videoCallListenerRegistration: ListenerRegistration? = nil
    private var audioCallListenerRegistration: ListenerRegistration? = nil

    func startListening(chatId: String) {
        stopListening()

        Task {
            do {
                let key = try await MessageManager.shared.fetchKey(chatId: chatId)

                listenerRegistration = FirebaseManager.shared.firestore.collection("chats").document(chatId).collection("messages").order(by: "sent_at", descending: false).addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Error listening for document changes: \(error)")
                        return
                    }
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found")
                        self.messages = []
                        return
                    }

                    self.messages = documents.map { document in
                        let data = document.data()
                        let encryptedMessage = data["message"] as? String ?? ""
                        let decryptedMessage: String
                        do {
                            decryptedMessage = try aesDecrypt(encryptedMessage: encryptedMessage, key: key)
                        } catch {
                            print("Error decrypting message: \(error)")
                            decryptedMessage = encryptedMessage // Fallback to encrypted message if decryption fails
                        }

                        return MessageModel(
                            messageId: document.documentID,
                            senderId: data["sender_id"] as? String ?? "",
                            message: decryptedMessage,
                            isPhoto: data["is_photo"] as? Bool ?? false,
                            isAudio: data["is_audio"] as? Bool ?? false,
                            sentAt: data["sent_at"] as? Timestamp ?? Timestamp(),
                            firstDeleteId: data["first_delete_id"] as? String ?? "",
                            secondDeleteId: data["second_delete_id"] as? String ?? "",
                            isDeletedForAll: data["is_deleted_for_all"] as? Bool ?? false
                        )
                    }

                    let currentUid = UserManager.shared.getCurrentUserID()
                    if let lastMessage = self.messages.last, lastMessage.senderId != currentUid {
                        MessageManager.markLastMessageAsRead(chatId: chatId, currentUid: currentUid)
                    }
                }

                DispatchQueue.main.async {
                    self.startStatusListener()
                    self.startChatListener(chatId: chatId)
                    self.startVideoCallListener(chatID: chatId)
                    self.startAudioCallListener(chatID: chatId)
                }

            } catch {
                print("Error fetching key: \(error)")
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
    
    private func startChatListener(chatId: String) {
        chatListenerRegistration = FirebaseManager.shared.firestore.collection("chats")
            .document(chatId)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error listening for document changes: \(error)")
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    print("No document found")
                    self.isLastMessageRead = true
                    return
                }
                
                let data = document.data() ?? [:]
                self.isLastMessageRead = data["is_last_message_read"] as? Bool ?? true
            }
    }
    
    private func startVideoCallListener(chatID: String) {
        guard videoCallListenerRegistration == nil else {
            print("Listener already active")
            return
        }

        Task {
            guard let secondUid = await MessageManager.shared.verifyOtherParticipantUid(chatID: chatID) else {
                print("Unable to verify other participant UID")
                return
            }

            let currentUserId = UserManager.shared.getCurrentUserID()

            videoCallListenerRegistration = FirebaseManager.shared.firestore.collection("calls")
                .whereField("call_started", isEqualTo: true)
                .whereField("is_video", isEqualTo: true)
                .whereField("receiver_id", isEqualTo: currentUserId)
                .whereField("caller_id", isEqualTo: secondUid)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Error listening for call creation: \(error.localizedDescription)")
                        return
                    }

                    guard let snapshot = querySnapshot else {
                        print("No documents found")
                        self.videoCallExists = false
                        return
                    }
                    self.videoCallExists = !snapshot.isEmpty
                }
        }
    }
    
    private func startAudioCallListener(chatID: String) {
        guard audioCallListenerRegistration == nil else {
            print("Listener already active")
            return
        }

        Task {
            guard let secondUid = await MessageManager.shared.verifyOtherParticipantUid(chatID: chatID) else {
                print("Unable to verify other participant UID")
                return
            }

            let currentUserId = UserManager.shared.getCurrentUserID()

            audioCallListenerRegistration = FirebaseManager.shared.firestore.collection("calls")
                .whereField("call_started", isEqualTo: true)
                .whereField("is_video", isEqualTo: false)
                .whereField("receiver_id", isEqualTo: currentUserId)
                .whereField("caller_id", isEqualTo: secondUid)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print("Error listening for call creation: \(error.localizedDescription)")
                        return
                    }

                    guard let snapshot = querySnapshot else {
                        print("No documents found")
                        self.audioCallExists = false
                        return
                    }
                    self.audioCallExists = !snapshot.isEmpty
                }
        }
    }
    
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
        statusListenerRegistration?.remove()
        statusListenerRegistration = nil
        chatListenerRegistration?.remove()
        chatListenerRegistration = nil
        videoCallListenerRegistration?.remove()
        videoCallListenerRegistration = nil
        audioCallListenerRegistration?.remove()
        audioCallListenerRegistration = nil
    }
}
