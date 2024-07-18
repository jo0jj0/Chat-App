//
//  ContactsViewModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 25.04.2024.
//

import Foundation

@MainActor
final class ContactsViewModel: ObservableObject {
    
    @Published var showSheet: Bool = false
    @Published var searchText: String = ""
    @Published var currentTab: Tab = .home
    @Published var showLogoutDialog: Bool = false
    @Published var isSearching: Bool = false
    @Published var goToChat: Bool = false
    
    func createChat(userId: String, userName: String, userProfilePicture: String, userToken: String) {
        Task {
            do {
                let _: () = try await MessageManager.shared.createChat(secondUserId: userId, secondUserName: userName, secondUserProfilePicture: userProfilePicture, secondToken: userToken)
            } catch {
                print("Error create chat: \(error.localizedDescription)")
            }
        }
    }
    

}
    

