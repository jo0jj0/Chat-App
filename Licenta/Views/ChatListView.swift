//
//  Chat-List.swift
//  Licenta
//
//  Created by Georgiana Costea on 13.03.2024.
//

import SwiftUI
import Lottie
import Firebase


struct ChatListView: View {
    @Binding var showTabBar: Bool
    @Environment(\.isPreview) private var isPreview
    @AppStorage("log_status") var logStatus: Bool = false
    
    @ObservedObject private var viewModel = ChatListViewModel()
    @StateObject var chatListListener = ChatListListener()

    @State var chatContact: ContactsModel?
    
    let currentUser = FirebaseManager.shared.auth.currentUser?.uid
    
    var body: some View {
        NavigationStack {
                  ZStack {
                      MainBackground()
                      VStack {
                          Spacer()
                          ZStack(alignment: .topTrailing) {
                              if chatListListener.chats.isEmpty {
                                  VStack(spacing: 0.0) {
                                      GeometryReader { _ in
                                          if let bundle = Bundle.main.path(forResource: "ChatListAnimation", ofType: "json") {
                                              LottieView {
                                                  await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                                              }
                                              .playing(loopMode: .loop)
                                          }
                                      }
                                      Text("No chats found.")
                                          .padding()
                                          .frame(maxWidth: .infinity, maxHeight: .infinity)
                                  }
                                  .padding()
                              } else {
                                  List {
                                      ForEach(chatListListener.chats, id: \.id) { chat in
                                          if !chat.lastMessageReceiverUid.isEmpty && chat.firstDeleteId != currentUser && chat.secondDeleteId != currentUser {
                                              if chat.firstHiddenId != currentUser && chat.secondHiddenId != currentUser {
                                                  ZStack {
                                                      ZStack {
                                                          if chat.firstUid == currentUser {
                                                              chatRowSecond(for: chat, status: chatListListener.userStatuses[chat.secondUid] ?? "offline", currentUid: currentUser ?? "")
                                                          } else {
                                                              chatRowFirst(for: chat, status: chatListListener.userStatuses[chat.firstUid] ?? "offline", currentUid: currentUser ?? "")
                                                          }
                                                      }
                                                      NavigationLink(destination: ChatView(showTabBar: $showTabBar, chatId: chat.id, contactId: "")) {
                                                          EmptyView()
                                                      }
                                                      .frame(width: 0)
                                                      .opacity(0)
                                                  }
                                                  .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                      Button {
                                                          viewModel.chatIdToDelete = chat.id
                                                          viewModel.showDeleteChatDialog = true
                                                      } label: {
                                                          Label("", systemImage: "trash.fill")
                                                      }
                                                      .tint(.red)
                                                  }
                                                  .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                                      Button {
                                                          viewModel.chatIdToHide = chat.id
                                                          viewModel.showHideChatDialog = true
                                                      } label: {
                                                          Label("", systemImage: "eye.slash.fill")
                                                      }
                                                      .tint(.circle1.opacity(0.3))
                                                  }
                                              }
                                          }
                                      }
                                      .listRowBackground(Color.clear)
                                      .listRowSeparator(.hidden)
                                  }
                                  .safeAreaPadding(.bottom, 80)
                                  .listRowSpacing(-10.0)
                                  .listStyle(.plain)
                                  .background(.clear)
                                  .ignoresSafeArea()
                                  .scrollContentBackground(.hidden)
                                  .refreshable {
                                      if !isPreview {
                                          chatListListener.startListening()
                                      }
                                  }
                              }
                          }
                  }
                      .confirmationDialog("Delete Chat", isPresented: $viewModel.showDeleteChatDialog) {
                          Button("Delete chat", role: .destructive) {
                              if let chatId = viewModel.chatIdToDelete {
                                  MessageManager.shared.deleteAllMessages(chatId: chatId)
                              }
                          }
                      Button("Cancel", role: .cancel) { }
                  } message: {
                      Text("Are you sure you want to delete this chat?")
                  }
              
                  .confirmationDialog("Hide Chat", isPresented: $viewModel.showHideChatDialog) {
                      Button("Hide chat") {
                          if let chatId = viewModel.chatIdToHide {
                              MessageManager.shared.hideChat(chatId: chatId)
                          }
                      }
                      Button("Cancel", role: .cancel) { }
                  } message: {
                      Text("Are you sure you want to delete this chat?")
                  }
              }
            .onAppear {
                print("ChatListView appeared")
                if isPreview {
                    chatListListener.chats = [
//                        ChatModel(id: "MxzozNOYwoewogj9mlBqsuKPRjg2_NZdovIB5X2gezRIOwMunlLSwK1I2",
//                                  firstUid: "MxzozNOYwoewogj9mlBqsuKPRjg2",
//                                  secondUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
//                                  firstName: "Georgiana",
//                                  secondName: "Alexa",
//                                  firstProfilePicture:  "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FMxzozNOYwoewogj9mlBqsuKPRjg2%2FprofilePhoto.jpg?alt=media&token=458dee47-8759-48e8-9516-8559f21cb31b",
//                                  secondProfilePicture: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FNZdovIB5X2gezRIOwMunlLSwK1I2%2FprofilePhoto.jpg?alt=media&token=ed7bc084-aed0-4343-a759-72271e4e3621",
//                                  lastMessage: "Test",
//                                  lastMessageTime: Timestamp(),
//                                  isLastMessageRead: false,
//                                  lastMessageReceiverUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
//                                  isPhoto: false,
//                                  isAudio: false,
//                                  callId: "",
//                                  firstToken: "",
//                                  secondToken: "",
//                                  firstDeleteId: "",
//                                  secondDeleteId: "",
//                                  firstHiddenId: "",
//                                  secondHiddenId: "",
//                                  key: "key"),
//                        ChatModel(id: "MxzoaNOYwoewogj9mlBqsuKPRjg2_NZdovIB5X2gezRIOwMunlLSwK1I2",
//                                  firstUid: "MxzozNOYwoewogj9mlBqsuKPRjg2",
//                                  secondUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
//                                  firstName: "Alexa",
//                                  secondName: "Georgiana",
//                                  firstProfilePicture:  "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FMxzozNOYwoewogj9mlBqsuKPRjg2%2FprofilePhoto.jpg?alt=media&token=458dee47-8759-48e8-9516-8559f21cb31b",
//                                  secondProfilePicture: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FNZdovIB5X2gezRIOwMunlLSwK1I2%2FprofilePhoto.jpg?alt=media&token=ed7bc084-aed0-4343-a759-72271e4e3621",
//                                  lastMessage: "Test",
//                                  lastMessageTime: Timestamp(),
//                                  isLastMessageRead: true,
//                                  lastMessageReceiverUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
//                                  isPhoto: true,
//                                  isAudio: false,
//                                  callId: "",
//                                  firstToken: "",
//                                  secondToken: "",
//                                  firstDeleteId: "",
//                                  secondDeleteId: "",
//                                  firstHiddenId: "",
//                                  secondHiddenId: "",
//                                  key: "")
                    ]
                } else {
                    chatListListener.startListening()
                }
            }
            .onDisappear {
                print("ChatListView disappeared")
                if !isPreview {
                    chatListListener.stopListening()
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        if isPreview {
                            SheetHiddenChats(
                                showTabBar: $showTabBar
                            )
                        } else {   
                            ZStack {
                                SheetHiddenChats(showTabBar: $showTabBar)
                            }
                        }
                    } label: {
                        Image(systemName: "eraser.line.dashed")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        if isPreview {
                            SheetNewMessage(
                                showTabBar: $showTabBar, contactsArray: [
                                    ContactsModel(userId: "NZdovIB5X2gezRIOwMunlLSwK1I2",
                                                  profileImage: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FNZdovIB5X2gezRIOwMunlLSwK1I2%2FprofilePhoto.jpg?alt=media&token=ed7bc084-aed0-4343-a759-72271e4e3621",
                                                  user_name: "Alexa", token: "")
                                ]
                            )
                        } else {
                            ZStack {
                                SheetNewMessage(showTabBar: $showTabBar)
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                    }
                }
            }
        }
    }
    func chatRowSecond(for chat: ChatModel, status: String, currentUid: String) -> some View {
        HStack(spacing: 0.0){
            ZStack{
                if let profilePhotoURL = chat.secondProfilePicture {
                    AsyncImage(url: URL(string: profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: 80, height: 80)
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        default:
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .padding()
                        }
                    }
                }
                if status == "online" {
                    Image(systemName: "circle.fill")
                        .frame(width: 15)
                        .foregroundStyle(.green)
                        .offset(x: 18, y: 18)
                        .overlay {
                            Circle()
                                .stroke(.thinMaterial, lineWidth: 2)
                                .offset(x: 18, y: 18)
                        }
                } else {
                    Image(systemName: "circle.fill")
                        .frame(width: 15)
                        .foregroundStyle(.gray)
                        .offset(x: 18, y: 18)
                        .overlay {
                            Circle()
                                .stroke(.thinMaterial, lineWidth: 2)
                                .offset(x: 18, y: 18)
                        }
                }
            }
            VStack(alignment: .leading, spacing: 0.0){
                Text(chat.secondName)
                    .font(.title3.bold())
                
                if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
                    if chat.isPhoto {
                        Text("Photo.")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    } else if chat.isAudio {
                        Text("Audio Message.")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    } else {
                        Text(chat.lastMessage ?? "")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                } else {
                    if chat.isPhoto {
                        Text("Photo.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.gray))
                            .lineLimit(1)
                    } else if chat.isAudio {
                        Text("Audio Message.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.gray))
                            .lineLimit(1)
                    } else {
                        Text(chat.lastMessage ?? "")
                            .font(.subheadline)
                            .foregroundStyle(Color(.gray))
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 20) {
                if let lastMessageTime = chat.lastMessageTime {
                    if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
                        Text(viewModel.formatTimestamp(timestamp: lastMessageTime))
                            .font(.caption.bold())
                            .foregroundStyle(.primary)
                    } else {
                        Text(viewModel.formatTimestamp(timestamp: lastMessageTime))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity ,maxHeight: 90)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay() {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
        }
      //  .padding(.horizontal)
    }
    
    func chatRowFirst(for chat: ChatModel, status: String, currentUid: String) -> some View {
        HStack(spacing: 0.0){
            
            ZStack{
                if let profilePhotoURL = chat.firstProfilePicture {
                    AsyncImage(url: URL(string: profilePhotoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: 80, height: 80)
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        default:
                            Image(systemName: "person.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .padding()
                        }
                    }
                }
                if status == "online" {
                                    Image(systemName: "circle.fill")
                                        .frame(width: 15)
                                        .foregroundStyle(.green)
                                        .offset(x: 18, y: 18)
                                        .overlay {
                                            Circle()
                                                .stroke(.thinMaterial, lineWidth: 2)
                                                .offset(x: 18, y: 18)
                                        }
                                } else {
                                    Image(systemName: "circle.fill")
                                        .frame(width: 15)
                                        .foregroundStyle(.gray)
                                        .offset(x: 18, y: 18)
                                        .overlay {
                                            Circle()
                                                .stroke(.thinMaterial, lineWidth: 2)
                                                .offset(x: 18, y: 18)
                                        }
                                }
            }
            VStack(alignment: .leading, spacing: 0.0){
                Text(chat.firstName)
                    .font(.title3.bold())
                if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
                    if chat.isPhoto {
                        Text("Photo.")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }  else if chat.isAudio {
                        Text("Audio Message.")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    } else {
                        Text(chat.lastMessage ?? "")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                } else {
                    if chat.isPhoto {
                        Text("Photo.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.gray))
                            .lineLimit(1)
                    } else if chat.isAudio {
                        Text("Audio Message.")
                            .font(.subheadline)
                            .foregroundStyle(Color(.gray))
                            .lineLimit(1)
                    } else {
                        Text(chat.lastMessage ?? "")
                            .font(.subheadline)
                            .foregroundStyle(Color(.gray))
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 20) {
                if let lastMessageTime = chat.lastMessageTime {
                    if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
                        Text(viewModel.formatTimestamp(timestamp: lastMessageTime))
                            .font(.caption.bold())
                            .foregroundStyle(.primary)
                    } else {
                        Text(viewModel.formatTimestamp(timestamp: lastMessageTime))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
//                Image(systemName: "checkmark")
//                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 14, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity ,maxHeight: 90)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay() {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
        }
       // .padding(.horizontal)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(showTabBar: .constant(true))
            .environment(\.isPreview, true)
    }
}
