//
//  SheetHiddenChats.swift
//  Licenta
//
//  Created by Georgiana Costea on 22.06.2024.
//

import SwiftUI
import Lottie
import Firebase

@MainActor
final class SheetHiddenChatsViewModel: ObservableObject {
    @Published var goToChat: Bool = false
    
}

struct SheetHiddenChats: View {
    @Binding var showTabBar: Bool
    @State var chatsArray: [ChatModel]?
    @StateObject var hiddenChatListListener = HiddenChatListListener()
    @Environment(\.isPreview) private var isPreview
    @StateObject var viewModel = SheetHiddenChatsViewModel()
    let currentUid = FirebaseManager.shared.auth.currentUser?.uid
    
    var body: some View {
        ZStack {
            if hiddenChatListListener.chats.isEmpty {
                VStack(spacing: 0.0) {
                    GeometryReader {_ in
                        if let bundle = Bundle.main.path(forResource: "HiddenListAnimation", ofType: "json") {
                            LottieView {
                                await LottieAnimation.loadedFrom(url: URL(filePath: bundle))
                            }
                            .playing(loopMode: .loop)
                        }
                    }
                    Text("No hidden chats.")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                .background(
                    Color(.babyBlue))
                .navigationTitle("Hidden Chats")
            } else {
                List {
                    ForEach(hiddenChatListListener.chats, id: \.id) { chat in
                        HStack {
                            ZStack {
                                HStack(spacing: 0.0) {
                                    VStack(alignment: .leading) {
                                        if chat.firstUid == currentUid {
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
                                                    if hiddenChatListListener.userStatuses[chat.secondUid] ?? "offline" == "online" {
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
                                                VStack(alignment: .leading, spacing: 0.0) {
                                                    Text(chat.secondName)
                                                        .font(.title3.bold())
                                                }
                                                Spacer()
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity ,maxHeight: 90)
                                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                            .overlay() {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
                                            }
                                        } else {
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
                                                    if hiddenChatListListener.userStatuses[chat.firstUid] ?? "offline" == "online" {
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
                                                }
                                                Spacer()
                                                
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity ,maxHeight: 90)
                                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                            .overlay() {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                NavigationLink (destination: ChatView(showTabBar: $showTabBar, chatId: chat.id , contactId: "")) {
                                    EmptyView()
                                }
                                .frame(width: 0)
                                .opacity(0)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    MessageManager.shared.unHideChat(chatId: chat.id)
                                } label: {
                                    Label("", systemImage: "eye.slash.fill")
                                }
                                .tint(.circle2.opacity(0.3))
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listRowSpacing(-10.0)
                .listStyle(.plain)
                .background(.clear)
                .scrollContentBackground(.hidden)
            }
            
        }
        .onAppear {
            if isPreview {
                hiddenChatListListener.chats = [
                    ChatModel(id: "MxzozNOYwoewogj9mlBqsuKPRjg2_NZdovIB5X2gezRIOwMunlLSwK1I2",
                              firstUid: "MxzozNOYwoewogj9mlBqsuKPRjg2",
                              secondUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
                              firstName: "Georgiana",
                              secondName: "Alexa",
                              firstProfilePicture:  "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FMxzozNOYwoewogj9mlBqsuKPRjg2%2FprofilePhoto.jpg?alt=media&token=458dee47-8759-48e8-9516-8559f21cb31b",
                              secondProfilePicture: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FNZdovIB5X2gezRIOwMunlLSwK1I2%2FprofilePhoto.jpg?alt=media&token=ed7bc084-aed0-4343-a759-72271e4e3621",
                              lastMessage: "Test",
                              lastMessageTime: Timestamp(),
                              isLastMessageRead: false,
                              lastMessageReceiverUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
                              isPhoto: false,
                              isAudio: false,
                              callId: "",
                              firstToken: "",
                              secondToken: "",
                              firstDeleteId: "",
                              secondDeleteId: "",
                              firstHiddenId: "",
                              secondHiddenId: "",
                              key: ""),
                    ChatModel(id: "MxzoaNOYwoewogj9mlBqsuKPRjg2_NZdovIB5X2gezRIOwMunlLSwK1I2",
                              firstUid: "MxzozNOYwoewogj9mlBqsuKPRjg2",
                              secondUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
                              firstName: "Alexa",
                              secondName: "Georgiana",
                              firstProfilePicture:  "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FMxzozNOYwoewogj9mlBqsuKPRjg2%2FprofilePhoto.jpg?alt=media&token=458dee47-8759-48e8-9516-8559f21cb31b",
                              secondProfilePicture: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FNZdovIB5X2gezRIOwMunlLSwK1I2%2FprofilePhoto.jpg?alt=media&token=ed7bc084-aed0-4343-a759-72271e4e3621",
                              lastMessage: "Test",
                              lastMessageTime: Timestamp(),
                              isLastMessageRead: true,
                              lastMessageReceiverUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
                              isPhoto: true,
                              isAudio: false,
                              callId: "",
                              firstToken: "",
                              secondToken: "",
                              firstDeleteId: "",
                              secondDeleteId: "",
                              firstHiddenId: "",
                              secondHiddenId: "",
                              key: "")
                ]
            } else {
                hiddenChatListListener.fetchChats()
            }
        }
        .onDisappear {
            if !isPreview {
                hiddenChatListListener.stopListening()
            }
        }
        .navigationTitle("Hidden Chats")
        .background(.babyBlue)
    }
}

struct SheetHiddenChats_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SheetHiddenChats(showTabBar: .constant(true))
                .environment(\.isPreview, true)
        }
    }
}
