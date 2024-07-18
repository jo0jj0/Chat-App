//
//  LicentaApp.swift
//  Licenta
//
//  Created by Georgiana Costea on 13.03.2024.
//

import SwiftUI
import Firebase
import StreamChat

@main
struct LicentaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) {
                   handleScenePhaseChange()
               }
    }
    
    func handleScenePhaseChange() {
        switch scenePhase {
        case .inactive, .background:
            updateStatus(status: "offline")
        case .active:
            updateStatus(status: "online")
        default:
            break
        }
    }
    
    func updateStatus(status: String) {
        guard let userid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData: [String:Any] = [
            "status": status
        ]
        FirebaseManager.shared.firestore.collection("users_status").document(userid).setData(userData, merge: true) { error in
            if let error = error {
                print("Error updating status: \(error.localizedDescription)")
            } else {
                print("Status updated successfully to \(status)")
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let config = ChatClientConfig(apiKey: .init("xcz93p3wmgrq"))

        ChatClient.shared = ChatClient(config: config)
        return true
    }
}
