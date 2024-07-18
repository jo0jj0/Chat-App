//
//  CallListenerForCurrentUser.swift
//  Licenta
//
//  Created by Georgiana Costea on 23.06.2024.
//

import Foundation
import FirebaseFirestore

class CallListener: ObservableObject {
    @Published var isCurrentUserInCall = false
    @Published var isCallEnded = false
    @Published var showAlert: Bool = false

    private var listenerRegistrationCurrentUser: ListenerRegistration? = nil
    private var listenerRegistrationCallEnd: ListenerRegistration? = nil

    func startListenerForCurrentUser(callId: String) {
        stopListeningCurrentUser()
        
        guard listenerRegistrationCurrentUser == nil else {
            print("Listener already active")
            return
        }
        let currentUserId = UserManager.shared.getCurrentUserID()
        
        listenerRegistrationCurrentUser = FirebaseManager.shared.firestore.collection("calls")
            .whereField("call_started", isEqualTo: true)
            .whereField("receiver_id", isEqualTo: currentUserId)
            .whereField("caller_id", isEqualTo: currentUserId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening for call creation: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    print("No documents found")
                    self.isCurrentUserInCall = false
                    return
                }
                DispatchQueue.main.async {
                    self.isCurrentUserInCall = !snapshot.isEmpty
                    self.startListenerCallEnded(callID: callId)
                }
            }
    }
    
    func startListenerCallEnded(callID: String) {
        
        guard listenerRegistrationCallEnd == nil else {
            print("Listener already active")
            return
        }
        
        
        listenerRegistrationCallEnd = FirebaseManager.shared.firestore.collection("calls").document(callID)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    print("Error listening for call updates: \(error.localizedDescription)")
                    return
                }
                
                guard let document = documentSnapshot else {
                    print("Document does not exist")
                    self.isCallEnded = false
                    return
                }
                
                if let callStarted = document.data()?["call_started"] as? Bool {
                    self.isCallEnded = callStarted
                    if callStarted == false {
                        self.showAlert = true
                    }
                } else {
                    self.isCallEnded = false
                }
            }
    }
    func stopListeningCurrentUser() {
        listenerRegistrationCurrentUser?.remove()
        listenerRegistrationCurrentUser = nil
        listenerRegistrationCallEnd?.remove()
        listenerRegistrationCallEnd = nil
    }
}

