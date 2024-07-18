//
//  ProfileViewModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 05.04.2024.
//

import Foundation
import SwiftUI
import PhotosUI
import Firebase

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var currentTab: Tab = .home
    @Published var showLogoutDialog: Bool = false
    @Published var showDeleteAccountDialog: Bool = false
    @Published var deleteAccountPassword: String = ""
    @Published var resetEmailAddress = ""
    @Published var alertMessage: String = ""
    @Published var showPasswordAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var showResetPasswordAlert: Bool = false
    @Published var showChangeNameAlert: Bool = false
    @Published var photoPickerItem: PhotosPickerItem?
    @MainActor
    @Published var currentUser: UserModel?
    @Published var currentUID = UserManager.shared.getCurrentUserID()
    @Published var showDeleteAccountAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var success: Bool = false
    @Published var showNameAlert: Bool = false
    @Published var nameErrorMessage: String = ""
    @Published var newName: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    
    func authenticateAndDelete(password: String) {
        isLoading = true
        Task {
            do {
                let authenticated = try await AuthenticationManager.shared.reauthenticate(password: password)
                if authenticated {
                    try await deleteAccount()
                } else {
                    await presenAlertDelete("Wrong password")
                    isLoading = false
                }
            } catch {
                await presenAlertDelete(error.localizedDescription)
                isLoading = false
            }
        }
    }
    
    private func deleteAccount() async throws {
        do {
            let deleted = try await AuthenticationManager.shared.deleteAccount()
            if deleted {
                handleSuccess { [weak self] in
                    self?.logStatus = false 
                }
            } else {
                await presenAlertDelete("Error deleting account")
                showDeleteAccountDialog = true
            }
        } catch {
            await presenAlertDelete(error.localizedDescription)
        }
    }
    
    private func handleSuccess(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.success = true
            completion()
        }
    }

    func formatDate(timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    func presentAlertName(_ message: String) async {
        await MainActor.run {
            self.showNameAlert = true
            self.nameErrorMessage = message
            self.isLoading = false
            self.newName = ""
        }
    }
    
    func presenAlertDelete(_ message: String) async {
        await MainActor.run {
            self.showDeleteAccountAlert = true
            self.errorMessage = message
            self.isLoading = false
            self.deleteAccountPassword = ""
        }
    }
    
    func presentAlertPassword(_ message: String) async {
        await MainActor.run {
            showPasswordAlert = true
            alertMessage = message
            isLoading = false
            resetEmailAddress = ""
        }
    }
    
    func changeName() {
        Task {
            do {
                if newName.count <= 2 {
                    await presentAlertName("Please enter an valid name.")
                    return
                }
                isLoading = true
                UserManager.shared.changeUserName(newName: newName)
                await presentAlertPassword("Your name was successfully updated.")
                newName = ""
                isLoading = false
            }
        }
    }
    
    func sendRestLink() {
        Task {
            do {
                if resetEmailAddress.isEmpty {
                    await presentAlertPassword("Please enter an email address.")
                    return
                }
                isLoading = true
                try await AuthenticationManager.shared.passwordReset(email: resetEmailAddress)
                await presentAlertPassword("Check your email inbox.")
                resetEmailAddress = ""
                isLoading = false
            } catch {
                await presentAlertPassword(error.localizedDescription)
            }
        }
    }
    
    func fetchCurrentUser() async {
        do {
            let user = try await UserManager.getUser(userId: currentUID)
            currentUser = user
        } catch {
            print("Error: \(error)")
        }
    }
    
    func fetchedCurrentUser() {
        Task {
            await fetchCurrentUser()
        }
    }
}

