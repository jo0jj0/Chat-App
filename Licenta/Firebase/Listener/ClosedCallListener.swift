//
//  ClosedCallListener.swift
//  Licenta
//
//  Created by Georgiana Costea on 23.06.2024.
//

import Foundation
import FirebaseFirestore

class ClosedCallListener: ObservableObject {
    @Published var isCallEnded = false

    private var listenerRegistrationCurrentUser: ListenerRegistration? = nil

    func StartListenerCallEnded(callID: String) {
        
        guard listenerRegistrationCurrentUser == nil else {
            print("Listener already active")
            return
        }
        
        
        listenerRegistrationCurrentUser = FirebaseManager.shared.firestore.collection("calls").document(callID)
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
                } else {
                    self.isCallEnded = false
                }
            }
    }

    func stopListeningCallEnded() {
        listenerRegistrationCurrentUser?.remove()
        listenerRegistrationCurrentUser = nil
    }
}
