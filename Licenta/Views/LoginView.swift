//
//  LoginView.swift
//  Licenta
//
//  Created by Georgiana Costea on 24.03.2024.
//

import SwiftUI
import Lottie
import PhotosUI


struct LoginView: View {
    
    enum FocusableField: Hashable, CaseIterable {
        case name, email, password, confirmPassword
    }
    
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: FocusableField?
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack {
                MainBackground()
                ScrollView {
                    VStack(alignment: .center, spacing: 20){
                        Section{
                            if viewModel.activeTab == .createAccount {
                                HStack {
                                    Spacer()
                                    Button{ } label: {
                                        PhotosPicker(selection: $viewModel.photoPickerItem, matching: .livePhotos) {
                                            if let image = self.viewModel.profilePicture {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(Circle())
                                                    .padding()
                                            } else {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 100, height: 100)
                                                    .foregroundColor(.primary)
                                                    .padding()
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                HStack(spacing: 0){
                                    TextField("Name", text: $viewModel.userName)
                                        .textContentType(.name)
                                        .keyboardType(.emailAddress)
                                        .customTextField("person")
                                        .focused($focusedField, equals: .name)
                                        .onTapGesture {
                                            viewModel.isNameFocused = true
                                            viewModel.isEmailFocused = false
                                            viewModel.isPasswordFocused = false
                                            viewModel.isConfirmPasswordFocused = false
                                            
                                        }
                                    Button("", systemImage: "info.circle") {
                                        viewModel.showingPopover = true
                                    }
                                    .popover(isPresented: $viewModel.showingPopover) {
                                        Text("Please enter a name with at least 5 characters.")
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                            .presentationCompactAdaptation(.popover)
                                            .padding()
                                    }
                                    .foregroundStyle(.secondary)
                                    .labelStyle(.iconOnly)
                                    .frame(alignment: .center)
                                    .background(Color.gray.opacity(0.2).cornerRadius(10))
                                    .padding(.trailing,20)
                                }
                            }
                            if viewModel.activeTab == .login{
                                TextField("Email", text: $viewModel.emailAddress)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .customTextField("at")
                                    .focused($focusedField, equals: .email)
                                    .onTapGesture {
                                        viewModel.isEmailFocused = true
                                        viewModel.isPasswordFocused = false
                                    }
                                HStack{
                                    if viewModel.showPassword{
                                        TextField("Password", text: $viewModel.password)
                                            .textContentType(.password)
                                            .customTextField("lock", 0, viewModel.activeTab == .login ? 10 : 0)
                                            .focused($focusedField, equals: .password)
                                            .onTapGesture {
                                                viewModel.isPasswordFocused = true
                                                viewModel.isNameFocused = false
                                                viewModel.isEmailFocused = false
                                                viewModel.isConfirmPasswordFocused = false
                                            }
                                    } else{
                                        SecureField("Password", text: $viewModel.password)
                                            .textContentType(.password)
                                            .customTextField("lock", 0, viewModel.activeTab == .login ? 10 : 0)
                                            .focused($focusedField, equals: .password)
                                            .onTapGesture {
                                                viewModel.isPasswordFocused = true
                                                viewModel.isNameFocused = false
                                                viewModel.isEmailFocused = false
                                                viewModel.isConfirmPasswordFocused = false
                                            }
                                    }
                                }
                                .overlay(alignment: .trailing) {
                                    Button {
                                        viewModel.showPassword.toggle()
                                    } label: {
                                        Image(systemName: viewModel.showPassword ? "eye" : "eye.slash")
                                            .padding(.trailing, 25)
                                            .padding(.bottom, 10)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            } else {
                                HStack(spacing: 0){
                                    TextField("Email", text: $viewModel.emailAddress)
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .customTextField("at")
                                        .focused($focusedField, equals: .email)
                                        .onTapGesture {
                                            viewModel.isEmailFocused = true
                                            viewModel.isNameFocused = false
                                            viewModel.isPasswordFocused = false
                                            viewModel.isConfirmPasswordFocused = false
                                        }
                                    Button("", systemImage: "info.circle") {
                                        viewModel.showingPopover1 = true
                                    }
                                    .popover(isPresented: $viewModel.showingPopover1) {
                                        Text("Please provide a valid email address.")
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                            .presentationCompactAdaptation(.popover)
                                            .padding()
                                    }
                                    .foregroundStyle(.secondary)
                                    .labelStyle(.iconOnly)
                                    .frame(alignment: .center)
                                    .background(Color.gray.opacity(0.2).cornerRadius(10))
                                    .padding(.trailing,20)
                                }
                                HStack(spacing: 0){
                                    HStack {
                                        if viewModel.showPassword {
                                            TextField("Password", text: $viewModel.password)
                                                .textContentType(.password)
                                                .customTextField("lock", 0, viewModel.activeTab == .login ? 10 : 0)
                                                .focused($focusedField, equals: .password)
                                                .onTapGesture {
                                                    viewModel.isPasswordFocused = true
                                                    viewModel.isNameFocused = false
                                                    viewModel.isEmailFocused = false
                                                    viewModel.isConfirmPasswordFocused = false
                                                }
                                        } else {
                                            SecureField("Password", text: $viewModel.password)
                                                .textContentType(.password)
                                                .customTextField("lock", 0, viewModel.activeTab == .login ? 10 : 0)
                                                .focused($focusedField, equals: .password)
                                                .onTapGesture {
                                                    viewModel.isPasswordFocused = true
                                                    viewModel.isNameFocused = false
                                                    viewModel.isEmailFocused = false
                                                    viewModel.isConfirmPasswordFocused = false
                                                }
                                        }
                                    }
                                    .overlay(alignment: .trailing) {
                                        Button {
                                            viewModel.showPassword.toggle()
                                        } label: {
                                            Image(systemName: viewModel.showPassword ? "eye" : "eye.slash")
                                                .padding(.trailing, 25)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Button("", systemImage: "info.circle") {
                                        viewModel.showingPopover2 = true
                                    }
                                    .popover(isPresented: $viewModel.showingPopover2) {
                                        Text("Minimum 6 characters, 1 uppercase, 1 lowercase, 1 number. ")
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                            .presentationCompactAdaptation(.popover)
                                            .padding()
                                    }
                                    .foregroundStyle(.secondary)
                                    .labelStyle(.iconOnly)
                                    .frame(alignment: .center)
                                    .background(Color.gray.opacity(0.2).cornerRadius(10))
                                    .padding(.trailing,20)
                                }
                                HStack(spacing: 0){
                                    HStack {
                                        if viewModel.showConfirmPassword {
                                            TextField("Confirm Password", text: $viewModel.confirmPassword)
                                                .textContentType(.password)
                                                .customTextField("lock", 0, viewModel.activeTab != .login ? 10 : 0)
                                                .focused($focusedField, equals: .confirmPassword)
                                                .onTapGesture {
                                                    viewModel.isConfirmPasswordFocused = true
                                                    viewModel.isPasswordFocused = false
                                                    viewModel.isNameFocused = false
                                                    viewModel.isEmailFocused = false
                                                }
                                        } else {
                                            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                                                .textContentType(.password)
                                                .customTextField("lock", 0, viewModel.activeTab != .login ? 10 : 0)
                                                .focused($focusedField, equals: .confirmPassword)
                                                .onTapGesture {
                                                    viewModel.isConfirmPasswordFocused = true
                                                    viewModel.isPasswordFocused = false
                                                    viewModel.isNameFocused = false
                                                    viewModel.isEmailFocused = false
                                                }
                                        }
                                    }
                                    .overlay(alignment: .trailing) {
                                        Button {
                                            viewModel.showConfirmPassword.toggle()
                                        } label: {
                                            Image(systemName: viewModel.showConfirmPassword ? "eye" : "eye.slash")
                                                .padding(.trailing, 25)
                                                .padding(.bottom, 10)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Button("", systemImage: "info.circle") {
                                        viewModel.showingPopover3 = true
                                    }
                                    .popover(isPresented: $viewModel.showingPopover3) {
                                        Text("Minimum 6 characters, 1 uppercase, 1 lowercase, 1 number. ")
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                            .presentationCompactAdaptation(.popover)
                                            .padding()
                                    }
                                    .foregroundStyle(.secondary)
                                    .labelStyle(.iconOnly)
                                    .frame(alignment: .center)
                                    .background(Color.gray.opacity(0.2).cornerRadius(10))
                                    .padding(.trailing, 20)
                                    .padding(.bottom, 10)
                                }
                            }
                        } header: {
                            Picker("", selection: $viewModel.activeTab) {
                                ForEach(LoginViewModel.LoginTab.allCases, id: \.rawValue) {
                                    Text($0.rawValue)
                                        .tag($0)
                                }
                            }
                            .pickerStyle(.segmented)
                        } footer: {
                            VStack(alignment: .trailing, spacing: 12, content:  {
                                if viewModel.activeTab == .login {
                                    Button("Forgot Password?") {
                                        viewModel.showResetPasswordAlert = true
                                    }
                                    .font(.caption)
                                    .tint(Color.blue)
                                }
                                Button(action: loginAndRegister, label: {
                                    HStack(spacing: 15) {
                                        Text(viewModel.activeTab == .login ? "Login" : "Register")
                                            .foregroundStyle(.gray)
                                        Image(systemName: "arrow.right.circle")
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(.horizontal, 10)
                                })
                                .buttonStyle(.borderedProminent)
                                .showLoading(viewModel.isLoading)
                                .disabled(viewModel.buttonStatus)
                            })
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .animation(.snappy(duration: 0.3), value: viewModel.activeTab)
                    .listStyle(.insetGrouped)
                    .navigationTitle(viewModel.activeTab == .login ? "Login" : "Create Account")
                    .onSubmit(focusNextField)
                    .onChange(of: viewModel.photoPickerItem) { 
                        viewModel.handlePhotoPickerItem()
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .sheet(isPresented: $viewModel.showEmailVerificationView, content: {
                emailVerificationView()
                    .presentationDetents([.height(350)])
                    .presentationCornerRadius(25)
            })
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) { }
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
            .onChange(of: viewModel.activeTab, initial: false) { _, _ in
                viewModel.password = ""
                viewModel.confirmPassword = ""
            }
        }
    }
    
    private func focusNextField() {
        switch focusedField {
        case .name:
            focusedField = .email
        case .email:
            focusedField = .password
        case .password:
            focusedField = .confirmPassword
        case .confirmPassword:
            focusedField = .none
        case .none:
            break
        }
    }
    
    func loginAndRegister() {
        Task {
            viewModel.isLoading = true
            
            if viewModel.activeTab == .createAccount {
                guard !viewModel.emailAddress.isEmpty, !viewModel.password.isEmpty, !viewModel.confirmPassword.isEmpty, !viewModel.userName.isEmpty else {
                    await viewModel.presentAlert("Please fill in all fields.")
                    return
                }
            }
            do {
                if viewModel.activeTab == .login {
                    try await AuthenticationManager.shared.logInUser(email: viewModel.emailAddress, password: viewModel.password)
                    logStatus = true
                } else {
                    if viewModel.password == viewModel.confirmPassword {
                        AuthenticationManager.shared.registerUser(email: viewModel.emailAddress, password: viewModel.password) { result in
                            switch result {
                            case .success(_):
                                self.viewModel.showEmailVerificationView = true
                                self.viewModel.saveProfilePhoto()
                            case .failure(let error):
                                Task {
                                    await
                                    self.viewModel.presentAlert(error.localizedDescription)
                                }
                            }
                        }
                    } else {
                        await viewModel.presentAlert("Different Password")
                    }
                }
            } catch {
                await viewModel.presentAlert(error.localizedDescription)
            }
            viewModel.isLoading = false
        }
    }

@ViewBuilder
func emailVerificationView() -> some View {
    VStack(spacing: 6) {
        GeometryReader {_ in
            if let bundle = Bundle.main.path(forResource: "EmailAnimation", ofType: "json") {
                LottieView {
                    await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                }
                .playing(loopMode: .loop)
            }
        }
        Text("Verification")
            .font(.title.bold())
        Text("An verification email was sent. \nPlease verify your email.")
            .multilineTextAlignment(.center)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.vertical, 25)
    }
    .onReceive(Timer.publish(every: 2, on: .main, in: .default).autoconnect(), perform: { [self] _ in
        if let user = FirebaseManager.shared.auth.currentUser {
            user.reload()
            if user.isEmailVerified {
                viewModel.showEmailVerificationView = false
                logStatus = true
            }
        }
    })
}
}



#Preview {
    LoginView()
}


