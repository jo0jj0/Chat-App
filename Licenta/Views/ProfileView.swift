//
//  ProfileView.swift
//  Licenta
//
//  Created by Georgiana Costea on 05.04.2024.
//

import SwiftUI
import PhotosUI
import Firebase

struct ProfileView: View {
    @Binding var showTabBar: Bool
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("log_status") var logStatus: Bool = false
    @Environment(\.isPreview) private var isPreview
    @StateObject var profileListener = ProfileListener()

    var body: some View {
         NavigationStack {
             ZStack {
                 MainBackground()
                 VStack {
                     if let user = profileListener.user {
                         ZStack {
                             if let profileImageURL = user.profile_image {
                                 AsyncImage(url: URL(string: profileImageURL)) { phase in
                                     switch phase {
                                     case .success(let image):
                                         image
                                             .resizable()
                                             .aspectRatio(contentMode: .fit)
                                             .clipShape(Circle())
                                             .frame(width: 150, height: 150)
                                             .shadow(color: .secondary, radius: 10)
                                             .overlay(
                                                Circle()
                                                    .stroke(.secondary, lineWidth: 1)
                                                    .frame(width: 140, height: 140)
                                             )
                                     case .empty:
                                         ProgressView()
                                             .overlay(
                                                Circle()
                                                    .stroke(.secondary, lineWidth: 1)
                                                    .frame(width: 140, height: 140)
                                             )
                                             .padding(.vertical, 65)
                                     default:
                                         Image(systemName: "person.circle")
                                             .resizable()
                                             .aspectRatio(contentMode: .fit)
                                             .clipShape(Circle())
                                             .frame(width: 150, height: 150)
                                     }
                                 }
                             }
                         }
                         Text(user.user_name)
                             .font(.title.bold())
                             .padding(.bottom, 10)
                         List {
                             Section(header: Text("Edit profile")) {
                                 Button { } label: {
                                     PhotosPicker(selection: $viewModel.photoPickerItem, matching: .livePhotos) {
                                         Text("Change profile picture")
                                     }
                                     .onChange(of: viewModel.photoPickerItem) {
                                         if let photoPickerItem = viewModel.photoPickerItem {
                                             Task {
                                                 if let data = try? await photoPickerItem.loadTransferable(type: Data.self) {
                                                     UserManager.shared.editProfilePicture(newImage: data) { result in
                                                         switch result {
                                                         case .success(let downloadURL):
                                                             print("New profile picture URL: \(downloadURL)")
                                                         case .failure(let error):
                                                             print("Failed to update profile picture: \(error)")
                                                         }
                                                     }
                                                 }
                                             }
                                         }
                                     }
                                 }
                                 Button("Change name") {
                                     viewModel.showChangeNameAlert = true
                                 }
                                 Button("Reset password") {
                                     viewModel.showResetPasswordAlert = true
                                 }
                                 Button("Delete account", role: .destructive) {
                                     viewModel.showDeleteAccountDialog.toggle()
                                 }
                             }
                             Section(header: Text("About user")) {
                                 HStack {
                                     Text("Email")
                                     Spacer()
                                     Text(user.email)
                                         .font(.footnote)
                                         .foregroundStyle(.gray)
                                 }
                                 HStack {
                                     Text("Since")
                                     Spacer()
                                     Text(viewModel.formatDate(timestamp: user.createdAt))
                                         .font(.footnote)
                                         .foregroundStyle(.gray)
                                 }
                             }
                         }
                         .background(
                            UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30)
                                .fill(Color.babyBlue)
                                .ignoresSafeArea()
                         )
                         .scrollContentBackground(.hidden)
                         // change name
                         .alert(viewModel.nameErrorMessage, isPresented: $viewModel.showNameAlert) { }
                         .alert("Change Name", isPresented: $viewModel.showChangeNameAlert) {
                             TextField("New Name", text: $viewModel.newName)
                             Button("Change") {
                                 viewModel.changeName()
                             }
                             Button("Cancel", role: .cancel) { }
                         } message: {
                                 Text("Your name must have at least 3 characters.")
                         }
                         //Reset Passwor
                         .alert(viewModel.alertMessage, isPresented: $viewModel.showPasswordAlert) { }
                         .alert("Reset Password", isPresented: $viewModel.showResetPasswordAlert, actions: {
                             TextField("Email Address", text: $viewModel.resetEmailAddress)
                                 .keyboardType(.emailAddress)
                             Button("Send reset email", role: .destructive) {
                                 viewModel.sendRestLink()
                             }
                             Button("Cancel", role: .cancel) {
                                 viewModel.resetEmailAddress = ""
                             }
                         }, message: {
                             Text("Enter your email address")
                         })
                         // Delete account
                         .alert(viewModel.errorMessage, isPresented: $viewModel.showDeleteAccountAlert) { }
                         .alert("Delete account", isPresented: $viewModel.showDeleteAccountDialog) {
                             SecureField("Password", text: $viewModel.deleteAccountPassword)
                             Button("Delete", role: .destructive) {
                                 
                                 viewModel.authenticateAndDelete(password: viewModel.deleteAccountPassword)

                             }
                             Button("Cancel", role: .cancel) { }
                         } message: {
                                 Text("Are you sure you want to delete this account?")
                         }
                     }
                 }
             }
             .onAppear {
                 if isPreview {
                     profileListener.user = UserModel(user_id: "userID", profile_image: "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0", email: "user@example.com", user_name: "Username", createdAt: Timestamp(date: Date()), token: "")
                 } else {
                     profileListener.startListening()
                 }
             }
             .onDisappear {
                 if !isPreview {
                     profileListener.stopListening()
                 }
             }
             .navigationTitle("Profile")
             .toolbar {
                 ToolbarItem(placement: .topBarTrailing) {
                     Menu {
                         Button("LogOut", systemImage: "xmark") {
                             viewModel.showLogoutDialog = true
                         }
                     } label: {
                         Image(systemName: "ellipsis")
                             .font(.title2)
                     }
                 }
             }
             .confirmationDialog("LogOut", isPresented: $viewModel.showLogoutDialog) {
                 Button("Leave", role: .destructive) {
                     Task {
                         do {
                             try AuthenticationManager.shared.logOut()
                             logStatus = false
                         } catch {
                             print(error)
                         }
                     }
                 }
                 Button("Cancel", role: .cancel) { }
             } message: {
                 Text("Are you sure you want to leave?")
             }
         }
     }
 }

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
       ProfileView(showTabBar: .constant(true))
            .environment(\.isPreview, true)
    }
}
