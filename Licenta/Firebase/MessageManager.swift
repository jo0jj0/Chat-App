//
//  MessageManager.swift
//  Licenta
//
//  Created by Georgiana Costea on 30.04.2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift


final class MessageManager {
    
    static let shared = MessageManager()
    private init() { }
    
    
    
    
    func createChat(secondUserId: String, secondUserName: String, secondUserProfilePicture: String, secondToken: String) async throws {
        do {
            let firstUserId = UserManager.shared.getCurrentUserID()
            guard let myuser = try await UserManager.getUser(userId: firstUserId) else {
                print("Nu s-a obtinut userul curent.")
                return
            }
            
            let key = generateEncryptionKey()
            
            let newChat: [String:Any] = [
                "id": "\(firstUserId)_\(secondUserId)",
                "first_uid": firstUserId,
                "first_name": myuser.user_name,
                "first_profile_picture": myuser.profile_image ?? "",
                "second_uid": secondUserId,
                "second_name": secondUserName,
                "second_profile_picture": secondUserProfilePicture,
                "last_message": "",
                "last_message_time": Timestamp(),
                "is_last_message_read": false,
                "last_message_receiver_uid": "",
                "first_token" : myuser.token,
                "second_token" : secondToken,
                "call_id" : UUID().uuidString,
                "first_delete_id": "",
                "second_delete_id": "",
                "first_hidden_id": "",
                "second_hidden_id": "",
                "key": key ?? ""
            ]
            let chatRef = FirebaseManager.shared.firestore.collection("chats").document("\(firstUserId)_\(secondUserId)")
            try await chatRef.setData(newChat, merge: false)
            print("Chat salvat cu succes!")
        } catch {
            print("Eroare la crearea chatului: \(error)")
            throw error
        }
    }
    
    func verifyChatExistence(secondUid: String, completion: @escaping (Bool) -> Void) {
        let currentUser = UserManager.shared.getCurrentUserID()
        let chatDocument1 = "\(currentUser)_\(secondUid)"
        let chatDocument2 = "\(secondUid)_\(currentUser)"
        
        let chatRef1 = FirebaseManager.shared.firestore.collection("chats").document(chatDocument1)
        let chatRef2 = FirebaseManager.shared.firestore.collection("chats").document(chatDocument2)
        chatRef1.getDocument { document1, _ in
            if let document1 = document1, document1.exists {
                completion(true)
            } else {
                chatRef2.getDocument { document2, _ in
                    if let document2 = document2, document2.exists {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    
    
    func getChats() async throws -> [ChatModel] {
        let currentUid = UserManager.shared.getCurrentUserID()
        let querySnapshot = try await FirebaseManager.shared.firestore.collection("chats")
            .whereFilter(
                Filter.orFilter(
                    [
                        Filter.whereField("first_uid", isEqualTo: currentUid),
                        Filter.whereField("second_uid", isEqualTo: currentUid)
                    ]
                )
            ).getDocuments()
        var chats: [ChatModel] = []
        for document in querySnapshot.documents {
            let userData = document.data()
            let chat = ChatModel(id: userData["id"] as? String ?? "",
                                 firstUid: userData["first_uid"] as? String ?? "",
                                 secondUid: userData["second_uid"] as? String ?? "",
                                 firstName: userData["first_name"] as? String ?? "",
                                 secondName: userData["second_name"] as? String ?? "",
                                 firstProfilePicture: userData["first_profile_picture"] as? String ?? "",
                                 secondProfilePicture: userData["second_profile_picture"] as? String ?? "",
                                 lastMessage: userData["last_message"] as? String ?? "",
                                 lastMessageTime: userData["last_time_message"] as? Timestamp,
                                 isLastMessageRead: userData["is_last_message_read"] as? Bool ?? true,
                                 lastMessageReceiverUid: userData["last_message_sender_uid"] as? String ?? "",
                                 isPhoto: userData["is_photo"] as? Bool ?? false,
                                 isAudio: userData["is_audio"] as? Bool ?? false,
                                 callId: userData["call_id"] as? String ?? "",
                                 firstToken: userData["first_token"] as? String ?? "",
                                 secondToken: userData["second_token"] as? String ?? "",
                                 firstDeleteId: userData["first_delete_id"] as? String ?? "",
                                 secondDeleteId: userData["second_delete_id"] as? String ?? "",
                                 firstHiddenId: userData["first_delete_id"] as? String ?? "",
                                 secondHiddenId: userData["first_delete_id"] as? String ?? "",
                                 key: userData["key"] as? String ?? ""
)
            
            chats.append(chat)
        }
        return chats
    }
    
    func getChat(id: String) async throws -> ChatModel? {
        print("Attempting to get document with id: \(id)")
        do {
            let document = try await FirebaseManager.shared.firestore.collection("chats").document(id).getDocument()
            
            guard document.exists else {
                print("Document does not exist")
                return nil
            }
            guard let chatData = document.data() else {
                print("No data found in document")
                return nil
            }
            print(chatData)
            let chat = ChatModel(id: document["id"] as? String ?? "",
                                 firstUid: document["first_uid"] as? String ?? "",
                                 secondUid: document["second_uid"] as? String ?? "",
                                 firstName: document["first_name"] as? String ?? "",
                                 secondName: document["second_name"] as? String ?? "",
                                 firstProfilePicture: document["first_profile_picture"] as? String ?? "",
                                 secondProfilePicture: document["second_profile_picture"] as? String ?? "",
                                 lastMessage: document["last_message"] as? String ?? "",
                                 lastMessageTime: document["last_time_message"] as? Timestamp,
                                 isLastMessageRead: document["is_last_message_read"] as? Bool ?? true,
                                 lastMessageReceiverUid: document["last_message_sender_uid"] as? String ?? "",
                                 isPhoto: document["is_photo"] as? Bool ?? false,
                                 isAudio: document["is_audio"] as? Bool ?? false,
                                 callId: document["call_id"] as? String ?? "",
                                 firstToken: document["first_token"] as? String ?? "",
                                 secondToken: document["second_token"] as? String ?? "",
                                 firstDeleteId: document["first_delete_id"] as? String ?? "",
                                 secondDeleteId: document["second_delete_id"] as? String ?? "",
                                 firstHiddenId: document["first_delete_id"] as? String ?? "",
                                 secondHiddenId: document["first_delete_id"] as? String ?? "",
                                 key: document["key"] as? String ?? ""
            )
            return chat
        } catch {
            print("Error getting document: \(error)")
            throw error
        }
    }
    
    func sendMessage(chatId: String, message: String, isPhoto: Bool, isAudio: Bool, imageData: Data? = nil, audioData: Data? = nil, key: String) {
        guard let senderId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        var encryptedMessage: String
        do {
            encryptedMessage = try aesEncrypt(message: message, key: key)
        } catch {
            print("Error encrypting message: \(error.localizedDescription)")
            return
        }
        
        var messageData: [String: Any] = [
            "sender_id": senderId,
            "message": encryptedMessage,
            "is_photo": isPhoto,
            "is_audio": isAudio,
            "sent_at": Timestamp(),
            "first_delete_id": "",
            "second_delete_id": "",
            "is_deleted_for_all": false
        ]
        
        if isPhoto {
            guard let imageData = imageData else {
                print("Error: No image data provided for photo message.")
                return
            }
            
            uploadImage(imageData: imageData, chatId: chatId) { result in
                switch result {
                case .success(let downloadURL):
                    messageData["message"] = downloadURL.absoluteString
                    self.saveMessage(chatId: chatId, messageData: messageData)
                case .failure(let error):
                    print("Failed to upload image: \(error.localizedDescription)")
                }
            }
        } else if isAudio {
            guard let audioData = audioData else {
                print("Error: No audio data provided for audio message.")
                return
            }
            
            uploadAudio(audioData: audioData, chatId: chatId) { result in
                switch result {
                case .success(let downloadURL):
                    messageData["message"] = downloadURL.absoluteString
                    self.saveMessage(chatId: chatId, messageData: messageData)
                case .failure(let error):
                    print("Failed to upload audio: \(error.localizedDescription)")
                }
            }
        } else {
            saveMessage(chatId: chatId, messageData: messageData)
        }
    }
    
    private func saveMessage(chatId: String, messageData: [String: Any]) {
        FirebaseManager.shared.firestore.collection("chats").document(chatId).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
            }
        }
    }
    
    
    func hideMessageForOne(chatId: String, messageId: String) {
        guard let senderId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let messageDocRef = FirebaseManager.shared.firestore.collection("chats").document(chatId).collection("messages").document(messageId)
        
        messageDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let firstDeleteId = document.get("first_delete_id") as? String, firstDeleteId.isEmpty {
                    messageDocRef.updateData(["first_delete_id": senderId]) { err in
                        if let err = err {
                            print("Error updating message: \(err.localizedDescription)")
                        } else {
                            print("Message successfully updated with firstDeleteId")
                        }
                    }
                } else {
                    messageDocRef.updateData(["second_delete_id": senderId]) { err in
                        if let err = err {
                            print("Error updating message: \(err.localizedDescription)")
                        } else {
                            print("Message successfully updated with secondDeleteId")
                        }
                    }
                }
            } else {
                print("Message document does not exist")
            }
        }
    }
    
    func deleteMessageForAll(chatId: String, messageId: String) {
        let messageDocRef = FirebaseManager.shared.firestore.collection("chats").document(chatId).collection("messages").document(messageId)
        
        messageDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            messageDocRef.updateData(["is_deleted_for_all": true]) { err in
                if let err = err {
                    print("Error updating message: \(err.localizedDescription)")
                } else {
                    print("Message successfully marked as deleted for all")
                }
            }
        }
    }
    
    func deleteAllMessages(chatId: String) {
        let db = Firestore.firestore()
        let messagesRef = db.collection("chats").document(chatId).collection("messages")
        let currentUserID = UserManager.shared.getCurrentUserID()

        messagesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            let batch = db.batch()

            for document in documents {
                var updateData: [String: Any] = [:]

                if let firstDeleteID = document.data()["first_delete_id"] as? String, !firstDeleteID.isEmpty {
                    updateData["second_delete_id"] = currentUserID
                } else {
                    updateData["first_delete_id"] = currentUserID
                }

                let documentRef = messagesRef.document(document.documentID)
                batch.setData(updateData, forDocument: documentRef, merge: true)
            }

            batch.commit { (error) in
                if let error = error {
                    print("Error committing batch update: \(error.localizedDescription)")
                } else {
                    self.deleteChat(chatId: chatId)
                    print("Batch update successful")
                }
            }
        }
    }

    
    func hideChat(chatId: String) {
        guard let currentUID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let db = FirebaseManager.shared.firestore
        let chatDocRef = db.collection("chats").document(chatId)
        
        chatDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let firstDeleteId = document.get("first_hidden_id") as? String, firstDeleteId.isEmpty {
                    chatDocRef.updateData(["first_hidden_id": currentUID]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated with firstID")
                        }
                    }
                } else {
                    chatDocRef.updateData(["second_hidden_id": currentUID]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated with secondID")
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    } 
    
    func deleteChat(chatId: String) {
        guard let currentUID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let db = FirebaseManager.shared.firestore
        let chatDocRef = db.collection("chats").document(chatId)
        
        chatDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let firstDeleteId = document.get("first_delete_id") as? String, firstDeleteId.isEmpty {
                    chatDocRef.updateData(["first_delete_id": currentUID]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated with firstId")
                        }
                    }
                } else {
                    chatDocRef.updateData(["second_delete_id": currentUID]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated with secondId")
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func unHideChat(chatId: String) {
        let currentUid = UserManager.shared.getCurrentUserID()
        
        FirebaseManager.shared.firestore.collection("chats")
            .whereField("first_hidden_id", isEqualTo: currentUid)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error retrieving documents: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                for _ in documents {
                    let docRef = FirebaseManager.shared.firestore.collection("chats").document(chatId)
                    docRef.updateData(["first_hidden_id": ""]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Field first_hidden_id deleted successfully")
                        }
                    }
                }
            }
        
        FirebaseManager.shared.firestore.collection("chats")
            .whereField("second_hidden_id", isEqualTo: currentUid)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error retrieving documents: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                for _ in documents {
                    let docRef = FirebaseManager.shared.firestore.collection("chats").document(chatId)
                    docRef.updateData(["second_hidden_id": ""]) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Field second_hidden_id deleted successfully")
                        }
                    }
                }
            }
    }
    
    func updateChat(chatId: String, isLastMessageRead: Bool, receiverUid: String, isPhoto: Bool, isAudio: Bool) {
        let messageData: [String:Any] = [
            "is_last_message_read": isLastMessageRead,
            "last_message_time": Timestamp(),
            "last_message_receiver_uid": receiverUid,
            "is_photo": isPhoto,
            "is_audio": isAudio,
            "first_delete_id": "",
            "second_delete_id": ""
        ]
        
        FirebaseManager.shared.firestore.collection("chats").document(chatId).setData(messageData, merge: true) { error in
            if let error = error {
                print("Error updating message: \(error.localizedDescription)")
            } else {
                print("Chat updated successfully!")
            }
        }
    }
    
    static func markLastMessageAsRead(chatId: String, currentUid: String) {
        let chatRef = FirebaseManager.shared.firestore.collection("chats").document(chatId)
        
        chatRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let receiver = data?["last_message_receiver_uid"] as? String
                
                if receiver == currentUid {
                    chatRef.updateData(["is_last_message_read": true]) { error in
                        if let error = error {
                            print("Error updating message status: \(error.localizedDescription)")
                        } else {
                            print("Message status updated successfully!")
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func verifyOtherParticipantUid(chatID: String) async -> String? {
        let currentUser = UserManager.shared.getCurrentUserID()
        let firestore = FirebaseManager.shared.firestore
        do {
            let document = try await firestore.collection("chats").document(chatID).getDocument()
            if let data = document.data() {
                let firstUID = data["first_uid"] as? String
                let secondUID = data["second_uid"] as? String
                if let firstUID = firstUID, firstUID == currentUser {
                    print("Returning secondUID: \(String(describing: secondUID))")
                    return secondUID
                } else if let secondUID = secondUID, secondUID == currentUser {
                    print("Returning firstUID: \(String(describing: firstUID))")
                    return firstUID
                }
            }
            print("No matching UID found or document data is nil.")
            return nil
        } catch {
            print("Error fetching document: \(error)")
            return nil
        }
    }
    
    func uploadImage(imageData: Data, chatId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let photoId = UUID().uuidString
        let path = "Chat/\(chatId)/messages/\(photoId).jpg"
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
    
    func uploadAudio(audioData: Data, chatId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let audioId = UUID().uuidString
        let path = "Chat/\(chatId)/messages/\(audioId).mp3"
        let ref = FirebaseManager.shared.storage.reference().child(path)
        let metaData = StorageMetadata()
        metaData.contentType = "audio/m4a"
        ref.putData(audioData, metadata: metaData) { metaData, err in
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
    
    func getLastValidMessage(chatId: String, currentUserId: String) async throws -> String {
        let db = Firestore.firestore()
        let messagesRef = db.collection("chats").document(chatId).collection("messages")
        
        do {
            var querySnapshot = try await messagesRef
                .order(by: "sent_at", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            while let lastDoc = querySnapshot.documents.first {
                let lastDocData = lastDoc.data()
                
                if let firstDeletedId = lastDocData["first_delete_id"] as? String,
                   firstDeletedId == currentUserId {
                    querySnapshot = try await messagesRef
                        .order(by: "sent_at", descending: true)
                        .start(afterDocument: lastDoc)
                        .limit(to: 1)
                        .getDocuments()
                    continue
                }
                
                if let secondDeletedId = lastDocData["second_delete_id"] as? String,
                   secondDeletedId == currentUserId {
                    querySnapshot = try await messagesRef
                        .order(by: "sent_at", descending: true)
                        .start(afterDocument: lastDoc)
                        .limit(to: 1)
                        .getDocuments()
                    continue
                }
                
                if let isDeletedForAll = lastDocData["is_deleted_for_all"] as? Bool,
                   isDeletedForAll {
                    querySnapshot = try await messagesRef
                        .order(by: "sent_at", descending: true)
                        .start(afterDocument: lastDoc)
                        .limit(to: 1)
                        .getDocuments()
                    continue
                }
                
                if let message = lastDocData["message"] as? String {
                    return message
                } else {
                    return ""
                }
            }
            
            return ""
        } catch {
            print("Error getting documents: \(error)")
            throw error 
        }
    }
    
    func getLastValidTimestamp(chatId: String, currentUserId: String) async throws -> Timestamp? {
        let db = Firestore.firestore()
        let messagesRef = db.collection("chats").document(chatId).collection("messages")
        
        do {
            var querySnapshot = try await messagesRef
                .order(by: "sent_at", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            while let lastDoc = querySnapshot.documents.first {
                let lastDocData = lastDoc.data()
                
                if let firstDeletedId = lastDocData["first_delete_id"] as? String,
                   firstDeletedId == currentUserId {
                    querySnapshot = try await messagesRef
                        .order(by: "sent_at", descending: true)
                        .start(afterDocument: lastDoc)
                        .limit(to: 1)
                        .getDocuments()
                    continue
                }
                
                if let secondDeletedId = lastDocData["second_delete_id"] as? String,
                   secondDeletedId == currentUserId {
                    querySnapshot = try await messagesRef
                        .order(by: "sent_at", descending: true)
                        .start(afterDocument: lastDoc)
                        .limit(to: 1)
                        .getDocuments()
                    continue
                }
                
                if let isDeletedForAll = lastDocData["is_deleted_for_all"] as? Bool,
                   isDeletedForAll {
                    querySnapshot = try await messagesRef
                        .order(by: "sent_at", descending: true)
                        .start(afterDocument: lastDoc)
                        .limit(to: 1)
                        .getDocuments()
                    continue
                }
                
                if let sentAt = lastDocData["sent_at"] as? Timestamp {
                    return sentAt
                } else {
                    return nil
                }
            }
            
            return nil
        } catch {
            print("Error getting documents: \(error)")
            throw error
        }
    }

    func fetchKey(chatId: String) async throws -> String {
        let db = Firestore.firestore()
        let documentReference = db.collection("chats").document(chatId)
        
        do {
            let document = try await documentReference.getDocument()
            guard let data = document.data(), let username = data["key"] as? String else {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found in document"])
            }
            return username
        } catch {
            throw error
        }
    }
}
