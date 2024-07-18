//
//  ContactsView.swift
//  Licenta
//
//  Created by Georgiana Costea on 19.04.2024.
//

import SwiftUI
import Lottie

struct ContactsView: View {
    @ObservedObject private var viewModel = ContactsViewModel()
    @StateObject var contactsListener = ContactsListener()
    @Environment(\.isPreview) private var isPreview

    @Binding var showTabBar: Bool
    @AppStorage("log_status") var logStatus: Bool = false
    
    var filteredContacts: [ContactsModel] { 
        if viewModel.searchText.isEmpty {
            return contactsListener.contacts
        } else {
            return contactsListener.contacts.filter { $0.user_name.lowercased().contains(viewModel.searchText.lowercased()) }
        }
    }
    var body: some View {
        NavigationStack {
            ZStack {
                MainBackground()
                VStack(alignment: .leading) {
                    if !viewModel.isSearching {
                        Button("Add New Contact", systemImage: "person.badge.plus") {
                            viewModel.showSheet.toggle()
                        }
                        .foregroundStyle(.circle2)
                        .padding()
                        .sheet(isPresented: $viewModel.showSheet) {
                            SheetAddContacts()
                                .presentationDetents([.fraction(0.8)])
                                .presentationCornerRadius(50)
                                .presentationDragIndicator(.visible)
                        }
                    }
                    if contactsListener.contacts.isEmpty {
                        VStack(spacing: 0.0) {
                            GeometryReader {_ in
                                if let bundle = Bundle.main.path(forResource: "ContactsAnimation", ofType: "json") {
                                    LottieView {
                                        await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                                    }
                                    .playing(loopMode: .autoReverse)
                                }
                            }
                            Text("You need to add contacts first.")
                                .padding()
                                .frame(maxWidth: .infinity ,maxHeight: .infinity)
                            
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(filteredContacts, id: \.userId) { contact in
                                ZStack(alignment: .leading) {
                                    Button {
                                        MessageManager.shared.verifyChatExistence(secondUid: contact.userId) { exists in
                                            if exists {
                                                print("colectia exista")
                                            } else {
                                                print("colectia nu exista")
                                                viewModel.createChat(userId: contact.userId, userName: contact.user_name, userProfilePicture: contact.profileImage ?? "", userToken: contact.token)
                                            }
                                        }
                                    } label: {
                                        EmptyView()
                                    }
                                    NavigationLink (destination: ChatView(showTabBar: $showTabBar, chatId: "", contactId: contact.userId)) {
                                        HStack(spacing: 0.0) {
                                            VStack(alignment: .leading) {
                                                if let profileImageURL = contact.profileImage {
                                                    AsyncImage(url: URL(string: profileImageURL)) { phase in
                                                        switch phase {
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .clipShape(Circle())
                                                                .frame(width: 70, height: 70)
                                                        case .empty:
                                                            ProgressView()
                                                                .padding(25)
                                                            
                                                        default:
                                                            Image(systemName: "person.circle")
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .padding()
                                                                .frame(width: 70, height: 70)
                                                        }
                                                    }
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(contact.user_name)
                                                    .font(.title3.bold())
                                                if let status = contactsListener.userStatuses[contact.userId] {
                                                                 HStack(spacing: 1.0) {
                                                                     Image(systemName: "checkmark.circle.fill")
                                                                     Text(status == "online" ? "Online" : "Offline")
                                                                 }
                                                                 .font(.subheadline)
                                                                 .foregroundStyle(status == "online" ? .green : .gray)
                                                             }
                                                         }
                                        }
                                    }
                                }
                                
                                .listRowBackground(
                                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                        .fill(.thinMaterial)
                                )
                            }
                        }
                        .refreshable {
                            if !isPreview {
                                contactsListener.startListening()
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(
                            Color(.clear)
                        )
                        .listRowSpacing(10.0)
                    }
                }
            }
            .onAppear {
                if isPreview {
                    contactsListener.contacts = [
//                        ContactsModel(userId: "NZdovIB5X2gezRIOwMunlLSwK1I2",
//                                      profileImage: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FNZdovIB5X2gezRIOwMunlLSwK1I2%2FprofilePhoto.jpg?alt=media&token=ed7bc084-aed0-4343-a759-72271e4e3621",
//                                      user_name: "Alexa", token: "")
                    ]
                } else {
                    contactsListener.startListening()
                }
            }
            .onDisappear {
                if !isPreview {
                    contactsListener.stopListening()
                }
            }
            .searchable(text: $viewModel.searchText, isPresented: $viewModel.isSearching, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationTitle("Contacts")
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView(showTabBar: .constant(true))
            .environment(\.isPreview, true)
    }
}
