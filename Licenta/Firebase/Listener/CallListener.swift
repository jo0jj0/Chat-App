//
//  CallListener.swift
//  Licenta
//
//  Created by Georgiana Costea on 22.06.2024.
//

import Foundation
import FirebaseFirestore

//class CallListener: ObservableObject {
//    @Published var callExists: Bool = false
//    
//    private var listenerRegistration: ListenerRegistration? = nil
//    
//    func startListener(secondUid: String) {
//        guard listenerRegistration == nil else {
//            print("Listener already active")
//            return
//        }
//        
//        let currentUserId = UserManager.shared.getCurrentUserID()
//        
//        listenerRegistration = FirebaseManager.shared.firestore.collection("calls")
//            .whereField("call_started", isEqualTo: true)
//            .whereField("receiver_id", isEqualTo: currentUserId)
//            .whereField("caller_id", isEqualTo: secondUid)
//            .addSnapshotListener { querySnapshot, error in
//                if let error = error {
//                    print("Error listening for call creation: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let snapshot = querySnapshot else {
//                    print("No documents found")
//                    self.callExists = false
//                    return
//                }
//                
//                self.callExists = !snapshot.isEmpty
//            }
//    }
//      
//    func stopListening() {
//        listenerRegistration?.remove()
//        listenerRegistration = nil
//    }
//}
