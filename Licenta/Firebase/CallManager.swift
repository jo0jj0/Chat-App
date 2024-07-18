//
//  CallManager.swift
//  Licenta
//
//  Created by Georgiana Costea on 22.06.2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

final class CallManager {
    
    static let shared = CallManager()
    private init() { }
    
    
    func createCall(receiverId: String, isVideo: Bool) {
        let currentUid = FirebaseManager.shared.auth.currentUser?.uid
        let callData: [String:Any] = [
            "call_started": true,
            "created_at": Timestamp(),
            "duration": 0,
            "caller_id": currentUid ?? "",
            "receiver_id": receiverId,
            "is_video": isVideo
        ]
        
        FirebaseManager.shared.firestore.collection("calls").document().setData(callData, merge: true) { error in
            if let error = error {
                print("Error creating call: \(error.localizedDescription)")
            } else {
                print("Call created successfully!")
            }
        }
    }
    
    func getCallId() async -> String? {
        let currentUid = FirebaseManager.shared.auth.currentUser?.uid
        guard let currentUid = currentUid else {
            print("No current user")
            return nil
        }
        
        do {
            // First query with caller_id
            let querySnapshotCaller = try await FirebaseManager.shared.firestore.collection("calls")
                .whereField("call_started", isEqualTo: true)
                .whereField("caller_id", isEqualTo: currentUid)
                .getDocuments()
            
            if let document = querySnapshotCaller.documents.first {
                return document.documentID
            }
            
            // If no documents found, query with receiver_id
            let querySnapshotReceiver = try await FirebaseManager.shared.firestore.collection("calls")
                .whereField("call_started", isEqualTo: true)
                .whereField("receiver_id", isEqualTo: currentUid)
                .getDocuments()
            
            if let document = querySnapshotReceiver.documents.first {
                return document.documentID
            }
            
            print("No document found")
            return nil
        } catch {
            print("Error getting call ID: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateCall(callId: String, callStarted: Bool = false, duration: Int) {
            let callData: [String:Any] = [
                "call_started": callStarted,
                "duration": duration
            ]
            
            let callRef = FirebaseManager.shared.firestore.collection("calls").document(callId)
            
            callRef.setData(callData, merge: true) { error in
                if let error = error {
                    print("Error updating call: \(error.localizedDescription)")
                } else {
                    print("Call updated successfully!")
                }
            }
    }
    
    func getAllCallsForCurrentUser() async throws -> [CallModel] {
           let currentUserId = UserManager.shared.getCurrentUserID()
           
           let querySnapshot = try await FirebaseManager.shared.firestore.collection("calls")
               .whereFilter(Filter.orFilter(
                   [
                       Filter.whereField("receiver_id", isEqualTo: currentUserId),
                       Filter.whereField("caller_id", isEqualTo: currentUserId)
                   ]
               ))
               .order(by: "created_at", descending: true)
               .getDocuments()
           
           var calls: [CallModel] = []
           
           for document in querySnapshot.documents {
               let data = document.data()
               let callerId = data["caller_id"] as? String ?? ""
               let receiverId = data["receiver_id"] as? String ?? ""
               
               var userIdToFetch: String = ""
               if callerId == currentUserId {
                   userIdToFetch = receiverId
               } else if receiverId == currentUserId {
                   userIdToFetch = callerId
               }
               
               do {
                   let user = try await UserManager.getUser(userId: userIdToFetch)
                   
                   let call = CallModel(
                       id: document.documentID,
                       profilePicture: user?.profile_image ?? "",
                       userName: user?.user_name ?? "",
                       createdAt: data["created_at"] as? Timestamp ?? Timestamp(),
                       duration: data["duration"] as? Int ?? 0,
                       callerId: callerId,
                       receiverId: receiverId,
                       callStarted: data["call_started"] as? Bool ?? false
                   )
                   
                   calls.append(call)
               } catch {
                   print("Error fetching user details for user with ID \(userIdToFetch): \(error)")
               }
           }
           
           return calls
       }
}
