//
//  File.swift
//  Licenta
//
//  Created by Georgiana Costea on 31.03.2024.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI
import PhotosUI

@MainActor
final class LoginViewModel: ObservableObject{
    
    enum LoginTab: String, CaseIterable {
        case login = "Login"
        case createAccount = "Create Account"
    }
    
    @Published var activeTab: LoginTab = .login
    @Published var userName: String = ""
    @Published var emailAddress: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var showEmailVerificationView: Bool = false
    @Published var showResetPasswordAlert: Bool = false
    @Published var resetEmailAddress: String = ""
    @Published var profilePicture: UIImage?
    @Published var photoPickerItem: PhotosPickerItem?
    @Published var isNameFocused: Bool = false
    @Published var isEmailFocused: Bool = false
    @Published var isPasswordFocused: Bool = false
    @Published var isConfirmPasswordFocused: Bool = false
    @Published var showingPopover: Bool = false
    @Published var showingPopover1: Bool = false
    @Published var showingPopover2: Bool = false
    @Published var showingPopover3: Bool = false
    @Published var showPassword: Bool = false
    @Published var showConfirmPassword: Bool = false
    
    var buttonStatus: Bool {
        if activeTab == .login {
            return emailAddress.isEmpty || password.isEmpty
        }
        return emailAddress.isEmpty || password.isEmpty || confirmPassword.isEmpty || nameValidation(userName) == false || emailValidation(emailAddress) == false || passwordValidation(password) == false || passwordValidation(confirmPassword) == false
    }
    
    func presentAlert(_ message: String) async {
        await MainActor.run {
            showAlert = true
            alertMessage = message
            isLoading = false
            resetEmailAddress = ""
        }
    }
    
    func nameValidation (_ name: String) -> Bool {
        return name.count >= 5
    }
    
    func emailValidation(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return emailPredicate.evaluate(with: email)
    }
    
    func passwordValidation(_ password: String) -> Bool {
        
        guard password.count >= 6 else {
            return false
        }
        var hasUppercase = false
        var hasLowercase = false
        var hasNumber = false
        
        for character in password {
            if character.isUppercase {
                hasUppercase = true
            }
            if character.isLowercase {
                hasLowercase = true
            }
            if character.isNumber {
                hasNumber = true
            }
            if hasUppercase && hasLowercase && hasNumber {
                return true
            }
        }
        return false
    }
    
    func sendRestLink() {
        Task {
            do {
                if resetEmailAddress.isEmpty {
                    await presentAlert("Please enter an email address.")
                    return
                }
                isLoading = true
                try await AuthenticationManager.shared.passwordReset(email: resetEmailAddress)
                await presentAlert("Check your email inbox.")
                resetEmailAddress = ""
                isLoading = false
            } catch {
                await presentAlert(error.localizedDescription)
            }
        }
    }
    
    func handlePhotoPickerItem() {
        Task{
            if let photoPickerItem,
               let data = try? await photoPickerItem.loadTransferable(type: Data.self){
                if let image = UIImage(data: data) {
                    profilePicture = image
                }
            }
            photoPickerItem = nil
        }
    }
    
    func uploadImage(imageData: Data,  completion: @escaping (Result<URL, Error>) -> Void) {
        guard let userid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let path = "User/\(userid)/profilePhoto.jpg"
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
                    guard let url = url else { return }
                    self.saveNewUser(profilePictureURL: url)
                    
                }
            }
        }
    }
    
    func saveProfilePhoto() {
        guard let imageData = self.profilePicture?.jpegData(compressionQuality: 0.4) else {
            return
        }
        uploadImage(imageData: imageData) { result in
            switch result {
            case .success(let downloadURL):
                print("Image uploaded successfully! \(downloadURL.absoluteString)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveNewUser(profilePictureURL: URL) {
        guard let user_id = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let jwtManager = JWTManager(secretKey: "m22mhsgknv7dp2srwwnqkvdgajb3paey2zprsbwv6jpvqsr3njzhfegkn3349vkg", user_id: user_id)
        guard let token = jwtManager.generateToken() else { return }
        let userData: [String:Any] = [
            "user_id" : user_id,
            "email" : emailAddress,
            "profile_image" : profilePictureURL.absoluteString,
            "date_created" : Timestamp(),
            "user_name" : userName,
            "user_token" : token
        ]
        UserCredentials.addUserToGetStream(userId: user_id, token: token)
        FirebaseManager.shared.firestore.collection("users").document(user_id).setData(userData, merge: false)
    }
    
 
}


