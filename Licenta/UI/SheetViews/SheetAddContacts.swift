//
//  SheetAddContacts.swift
//  Licenta
//
//  Created by Georgiana Costea on 19.04.2024.
//

import SwiftUI

@MainActor
final class SheetAddConstantsViewModel: ObservableObject {
    
    @Published var searchText = ""
    @Published var usersArray: [SearchModel] = []
    @Published var isSearching: Bool = false
    @Published var addedUsers: Set<String> = []

    func searchUsers() async {
           do {
               let users = try await UserManager.searchUsers(name: searchText)
               await MainActor.run {
                   self.usersArray = users
               }
           } catch {
               print("Error searching users: \(error)")
           }
       }
    
    func addUser(_ user: SearchModel) {
        UserManager.saveNewContact(userId: user.user_id, name: user.user_name, profilePicture: user.profile_image ?? "", userToken: user.user_token)
          addedUsers.insert(user.user_id)
      }
}

struct SheetAddContacts: View {
    @ObservedObject private var viewModel = SheetAddConstantsViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    TextField("Search", text: $viewModel.searchText)
                        .padding(.leading, 24)
                }
                .onChange(of: viewModel.searchText) { newValue, oldValue in
                    Task {
                        guard !newValue.isEmpty else { return }
                        await viewModel.searchUsers()
                    }
                }
                .onTapGesture {
                    viewModel.isSearching = true
                }
                .padding()
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .overlay {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Spacer()
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                    .padding(.horizontal, 32)
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 32)
                Spacer()
                if !viewModel.searchText.isEmpty {
                    List {
                        if viewModel.searchText.count >= 2 {
                            ForEach(viewModel.usersArray, id: \.user_id) { user in
                                HStack {
                                    ZStack(alignment: .leading) {
                                        if let profileImageURL = user.profile_image {
                                            AsyncImage(url: URL(string: profileImageURL)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .clipShape(Circle())
                                                        .frame(width: 80, height: 80)
                                                case .empty:
                                                    ProgressView()
                                                        .padding(30)
                                                default:
                                                    Image(systemName: "person")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .padding()
                                                        .frame(width: 80, height: 80)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(.secondary, lineWidth: 1)
                                                                .frame(width: 75, height: 75)
                                                        )
                                                }
                                            }
                                        }
                                    }
                                    Text(user.user_name)
                                        .font(.title3.bold())
                                    Spacer()
                                    if viewModel.addedUsers.contains(user.user_id) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.primary)
                                            .padding()
                                            .buttonStyle(.bordered)

                                    } else {
                                        Button {
                                            viewModel.addUser(user)
                                        } label: {
                                            Text("Add")
                                                .padding(3)
                                                .foregroundStyle(.primary)
                                        }
                                        .buttonStyle(.bordered)

                                    }
                                }
                            }
                        }
                    }
                    .background(.babyBlue)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .background(.babyBlue)
    }
}


#Preview {
    SheetAddContacts()
}
