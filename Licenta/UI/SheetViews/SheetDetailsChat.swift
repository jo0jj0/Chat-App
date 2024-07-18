//
//  SheetDetailsChat.swift
//  Licenta
//
//  Created by Georgiana Costea on 14.05.2024.
//

import SwiftUI
import Firebase

@MainActor
final class SheetDetailsChatViewModel: ObservableObject {
    @Published var imageMessages: [MessageModel] = []
    @Published var profilePhotoURL: URL?
    @Published var selectedImageURL: String?
    @Published var showImageViewer = false

    private var messagesListener = MessagesListener()
    
    func startListening(id: String) {
        messagesListener.startListening(chatId: id)
        messagesListener.$messages
            .map { $0.filter { $0.isPhoto } }
            .assign(to: &$imageMessages)
    }
    
    func stopListening() {
        messagesListener.stopListening()
    }
}

struct SheetDetailsChat: View {
    @Binding var chatId: String?
    @Binding var contactId: String?
    @State var chatModel: ChatModel?
    @ObservedObject var viewModel = SheetDetailsChatViewModel()
    @Environment(\.isPreview) private var isPreview
    @Environment(\.presentationMode) var presentationMode
    
    let currentUser = FirebaseManager.shared.auth.currentUser?.uid
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Photos")
                        .frame(alignment: .leading)
                        .font(.callout)
                        .padding(.horizontal)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                Divider()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 3) {
                        ForEach(viewModel.imageMessages, id: \.self) { photo in
                            if photo.isPhoto {
                                AsyncImage(url: URL(string: photo.message)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 180, height: 180)
                                            .clipped()
                                            .onTapGesture { 
                                                viewModel.selectedImageURL = photo.message
                                                viewModel.showImageViewer = true
                                            }
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 180, height: 180)
                                    default:
                                        Image(systemName: "photo.on.rectangle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 180, height: 180)
                                            .clipped()
                                    }
                                }
                                .frame(width: 180, height: 180)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity)
            .background(.babyBlue)
                .task {
                    if isPreview {
                        viewModel.imageMessages = [ 
                            MessageModel(messageId: "text",
                                         senderId: "MxzozNOYwoewogj9mlBqsuKPRjg2",
                                         message: "Hello, how are you?",
                                         isPhoto: false,
                                         isAudio: false,
                                         sentAt: Timestamp(date: Date()),
                                         firstDeleteId: "",
                                         secondDeleteId: "",
                                         isDeletedForAll: false),
                            MessageModel(messageId: "1",
                                         senderId: "currentUid",
                                         message: "https://i0.wp.com/picjumbo.com/wp-content/uploads/camping-on-top-of-the-mountain-during-sunset-free-photo.jpg?w=600&quality=80",
                                         isPhoto: true,
                                         isAudio: false,
                                         sentAt: Timestamp(date: Date()),
                                         firstDeleteId: "",
                                         secondDeleteId: "",
                                         isDeletedForAll: false),
                            MessageModel(messageId: "2",
                                         senderId: "currentUid",
                                         message: "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0",
                                         isPhoto: true,
                                         isAudio: false,
                                         sentAt: Timestamp(date: Date()),
                                         firstDeleteId: "",
                                         secondDeleteId: "",
                                         isDeletedForAll: false),
                            MessageModel(messageId: "3",
                                         senderId: "currentUid",
                                         message: "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0",
                                         isPhoto: true,
                                         isAudio: false,
                                         sentAt: Timestamp(date: Date()),
                                         firstDeleteId: "",
                                         secondDeleteId: "",
                                         isDeletedForAll: false),
                            MessageModel(messageId: "4",
                                         senderId: "currentUid",
                                         message: "https://i0.wp.com/picjumbo.com/wp-content/uploads/camping-on-top-of-the-mountain-during-sunset-free-photo.jpg?w=600&quality=80",
                                         isPhoto: true,
                                         isAudio: false,
                                         sentAt: Timestamp(date: Date()),
                                         firstDeleteId: "",
                                         secondDeleteId: "",
                                         isDeletedForAll: false)
                        ]
                    }  else {
                        print(chatId ?? "")
                        print("This is contact id: \(contactId ?? "")")
                        guard let contactIdNotNill = contactId else { return }
                        if contactIdNotNill.isEmpty {
                            guard let chatIdNotNill = chatId else { return }
                            viewModel.startListening(id: chatId ?? "")
                            if !chatIdNotNill.isEmpty {
                                viewModel.startListening(id: chatIdNotNill)
                            }
                        } else {
                            if !contactIdNotNill.isEmpty {
                                let chatIdViewModel =  await verifyChatExistenceForString(secondUid: contactIdNotNill)
                                
                                print("Fetched chat ID: \(chatIdViewModel ?? "")")
                                viewModel.startListening(id: chatIdViewModel ?? "")
                                
                            }
                        }
                    }
                }
                .onDisappear {
                    viewModel.stopListening()
                }
                .safeAreaInset(edge: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            Button("Back", systemImage:  "chevron.left") {
                                presentationMode.wrappedValue.dismiss()
                                
                            }
                            Spacer()
//                            Menu {
//                                Button("Some Action", systemImage: "xmark") {
//                                    
//                                }
//                            } label: {
//                                Button("",systemImage: "ellipsis") {                                    
//                                }
//                            }
                            
                            
                        }
                        .padding(.horizontal)
                        VStack {
                            if chatModel?.firstUid == currentUser {
                                VStack {
                                    ZStack {
                                        if let profilePhotoURL = chatModel?.secondProfilePicture {
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
                                                }
                                            }
                                        }
                                    }
                                    Text(chatModel?.secondName ?? "nil")
                                        .font(.title3.bold())
                                }
                            } else {
                                HStack(alignment: .top) {
                                    VStack {
                                        ZStack {
                                            if let profilePhotoURL = chatModel?.firstProfilePicture {
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
                                                    }
                                                }
                                            }
                                        }
                                        Text(chatModel?.firstName ?? "nil")
                                            .font(.title3.bold())
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .background(.regularMaterial)
                }
            }
            .background(.babyBlue)
            .task {
                if isPreview {
                    chatModel = ChatModel(id: "MxzozNOYwoewogj9mlBqsuKPRjg2_NZdovIB5X2gezRIOwMunlLSwK1I2",
                                          firstUid: "MxzozNOYwoewogj9mlBqsuKPRjg2",
                                          secondUid: "NZdovIB5X2gezRIOwMunlLSwK1I",
                                          firstName: "Georgiana",
                                          secondName: "Alexa",
                                          firstProfilePicture:  "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FMxzozNOYwoewogj9mlBqsuKPRjg2%2FprofilePhoto.jpg?alt=media&token=458dee47-8759-48e8-9516-8559f21cb31b",
                                          secondProfilePicture: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/User%2FNZdovIB5X2gezRIOwMunlLSwK1I2%2FprofilePhoto.jpg?alt=media&token=ed7bc084-aed0-4343-a759-72271e4e3621",
                                          lastMessage: "Alt test", 
                                          lastMessageTime: Timestamp(),
                                          isLastMessageRead: false, 
                                          lastMessageReceiverUid: "",
                                          isPhoto: false,
                                          isAudio: false,
                                          callId: "",
                                          firstToken: "",
                                          secondToken: "",
                                          firstDeleteId: "",
                                          secondDeleteId: "",
                                          firstHiddenId: "",
                                          secondHiddenId: "",
                                          key: "")
                } else {
                    print(chatId ?? "")
                    print("This is contact id: \(contactId ?? "")")
                    guard let contactIdNotNill = contactId else { return }
                    if contactIdNotNill.isEmpty {
                        guard let chatIdNotNill = chatId else { return }
                        fetchedChat(id: chatId ?? "")
                        if !chatIdNotNill.isEmpty {
                            fetchedChat(id: chatIdNotNill)
                        }
                    } else {
                        if !contactIdNotNill.isEmpty {
                            let chatIdViewModel =  await verifyChatExistenceForString(secondUid: contactIdNotNill)
                            
                            print("Fetched chat ID: \(chatIdViewModel ?? "")")
                            fetchedChat(id: chatIdViewModel ?? "")
                            
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showImageViewer) {
                if let url = viewModel.selectedImageURL {
                    SheetPhotoBig(url: url)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(.ultraThinMaterial)
                }
            }
    }
    
    func verifyChatExistenceForString(secondUid: String) async -> String? {
        let currentUser = UserManager.shared.getCurrentUserID()
        
        let chatDocument1 = "\(currentUser)_\(secondUid)"
        let chatDocument2 = "\(secondUid)_\(currentUser)"
        
        let chatRef = FirebaseManager.shared.firestore.collection("chats")
        
        do {
            let querySnapshot = try await chatRef.whereField("id", in: [chatDocument1, chatDocument2]).getDocuments()
            
            if let document = querySnapshot.documents.first {
                print("Document id: \(document.documentID)")
                return document.documentID
            } else {
                return nil
            }
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchChat(id: String) async {
        do {
            let chat = try await MessageManager.shared.getChat(id: id)
            chatModel = chat
        } catch {
            print("Error: \(error)")
        }
    }
    
    func fetchedChat(id: String) {
        Task {
            await fetchChat(id: id)
            print("THIS IS CHAT VIEW MODEL ID \(id)")
        }
    }
}


struct SheetDetailsChat_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
          //  let chatModel = ChatModel(id: "someID", firstUid: "firstUid", secondUid: "secondUid", firstName: "John", secondName: "Doe", firstProfilePicture: "firstURL", secondProfilePicture: "secondURL", isOnline: "true")
            SheetDetailsChat(chatId: .constant("someID"), contactId: .constant("someID")/*, chatModel: chatModel*/)
            
        }
        .environment(\.isPreview, true)
        
    }
}
