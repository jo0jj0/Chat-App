import SwiftUI
import Firebase
import PhotosUI
import AVFoundation
import StreamVideo
import StreamVideoSwiftUI

enum CallType {
    case audio
    case video
}

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State var image: UIImage?
    @Environment(\.isPreview) private var isPreview
    @Binding var showTabBar: Bool
    @StateObject var messagesListener = MessagesListener()
    @Environment(\.dismiss) private var dismiss
    @State var chatId: String?
    @State var contactId: String?
    @State var isVideoCalling: Bool = false
    @StateObject private var voiceRecorder = VoiceRecorder()
    @State var callId: String?
    @State var userId: String?
    @State var secondId: String?
    @State var token: String?
    @State var isVideoCall: Bool?
    @State var firstPhoto: String?
    @State var secondPhoto: String?
    @State var userName: String?
    @State var showDeleteMessageDialog1: Bool = false
    @State var showDeleteMessageDialog2: Bool = false
    @State var messageIdToDelete: String?
    @State private var isCalling: Bool = false
    @State private var callType: CallType? = nil
    
    let currentUid = UserManager.shared.getCurrentUserID()
    // let currentUid = "currentUid"
    
    var body: some View {
        ZStack {
                   MainBackground()
                   ZStack {
                       if let chat = viewModel.chatModel {
                           VStack {
                               ScrollViewReader { proxy in
                                   ScrollView {
                                       LazyVStack {
                                           ForEach(messagesListener.messages, id: \.self) { message in
                                               HStack {
                                                   if message.firstDeleteId != currentUid && message.secondDeleteId != currentUid && !message.isDeletedForAll{
                                                       
                                                   
                                                   if message.senderId == currentUid {
                                                       
                                                       Spacer()
                                                       ZStack {
                                                           VStack(alignment: .trailing) {
                                                               if message.isPhoto {
                                                                   AsyncImage(url: URL(string: message.message)) { phase in
                                                                       switch phase {
                                                                       case .success(let image):
                                                                           image.resizable()
                                                                               .aspectRatio(contentMode: .fit)
                                                                               .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                               .containerRelativeFrame(.horizontal) { size, axis in
                                                                                   size * 0.6
                                                                               }
                                                                               .scaledToFill()
                                                                               .onTapGesture {
                                                                                   viewModel.selectedImageURL = message.message
                                                                                   viewModel.showImageViewer = true
                                                                               }
                                                                       case .empty:
                                                                           ProgressView().frame(width: 200, height: 200)
                                                                       default:
                                                                           Image(systemName: "photo.on.rectangle")
                                                                               .resizable()
                                                                               .aspectRatio(contentMode: .fit)
                                                                               .frame(width: 200, height: 200)
                                                                       }
                                                                   }
                                                               } else if message.isAudio {
                                                                   ProgressAudioMessage(message: message)
                                                                       .padding(10)
                                                                       .background(Color.circle2.opacity(1))
                                                                       .clipShape(ChatDialog(corners: [.topLeft, .topRight, .bottomLeft]))
                                                                       .frame(width: 230)
                                                               } else {
                                                                   Text(message.message)
                                                                       .foregroundColor(.white)
                                                                       .padding(20)
                                                                       .background(Color.circle2.opacity(0.8))
                                                                       .clipShape(ChatDialog(corners: [.topLeft, .topRight, .bottomLeft]))
                                                               }
                                                               HStack(spacing: 5) {
                                                                   Text(viewModel.formatTimestamp(timestamp: message.sentAt))
                                                                       .foregroundColor(.gray)
                                                                       .padding(.horizontal, 3)
                                                                   if message.messageId == messagesListener.messages.last?.messageId {
                                                                       Image(systemName: "checkmark")
                                                                           .foregroundColor(messagesListener.isLastMessageRead ? .circle1 : .gray)
                                                                   }
                                                               }
                                                               .font(.caption.bold())
                                                           }
                                                           .onLongPressGesture {
                                                               messageIdToDelete = message.messageId
                                                               showDeleteMessageDialog1 = true
                                                               print("Long Press")
                                                           }
                                                       }
                                                   } else {
                                                       VStack(alignment: .leading) {
                                                           if message.isPhoto {
                                                               AsyncImage(url: URL(string: message.message)) { phase in
                                                                   switch phase {
                                                                   case .success(let image):
                                                                       image.resizable()
                                                                           .aspectRatio(contentMode: .fit)
                                                                           .clipShape(RoundedRectangle(cornerRadius: 20))
                                                                           .containerRelativeFrame(.horizontal) { size, axis in
                                                                               size * 0.6
                                                                           }
                                                                           .scaledToFill()
                                                                           .onTapGesture {
                                                                               viewModel.selectedImageURL = message.message
                                                                               viewModel.showImageViewer = true
                                                                           }
                                                                   case .empty:
                                                                       ProgressView().frame(width: 70, height: 70)
                                                                   default:
                                                                       Image(systemName: "square.fill")
                                                                           .resizable()
                                                                           .aspectRatio(contentMode: .fit)
                                                                           .frame(width: 200, height: 200)
                                                                   }
                                                               }
                                                           } else if message.isAudio {
                                                               ProgressAudioMessage(message: message)
                                                                   .padding(10)
                                                                   .background(.thinMaterial)
                                                                   .clipShape(ChatDialog(corners: [.topLeft, .topRight, .bottomRight]))
                                                                   .frame(width: 230)
                                                           } else {
                                                               Text(message.message)
                                                                   .foregroundColor(.white)
                                                                   .padding(20)
                                                                   .background(Color.gray.opacity(0.8))
                                                                   .clipShape(ChatDialog(corners: [.topLeft, .topRight, .bottomRight]))
                                                           }
                                                           Text(viewModel.formatTimestamp(timestamp: message.sentAt))
                                                               .font(.caption)
                                                               .foregroundColor(.gray)
                                                               .padding(.horizontal, 3)
                                                       }
                                                       .onLongPressGesture {
                                                           messageIdToDelete = message.messageId
                                                           showDeleteMessageDialog2 = true
                                                           print("Long Press")
                                                       }
                                                       Spacer()
                                                   }}
                                               }
                                               .padding(.horizontal)
                                               .padding(.top, 5)
                                               .id(message.messageId)
                                           }
                                       }
                                   }
                                   .scrollDismissesKeyboard(.immediately)
                                   .onChange(of: viewModel.scrollToBottom) {
                                       withAnimation {
                                           if let lastMessageId = messagesListener.messages.last?.messageId {
                                               DispatchQueue.main.async {
                                                   withAnimation {
                                                       proxy.scrollTo(lastMessageId, anchor: .bottom)
                                                   }
                                               }
                                           }
                                       }
                                   }
                                   .confirmationDialog("Delete message", isPresented: $showDeleteMessageDialog1) {
                                       Button("Delete message", role: .destructive) {
                                           if let messageId = messageIdToDelete,  let chatId = chatId  {
                                               MessageManager.shared.hideMessageForOne(chatId: chatId, messageId: messageId)
                                           }
                                       }
                                       Button("Unsend message", role: .destructive) {
                                              if let messageId = messageIdToDelete, let chatId = chatId {
                                                  MessageManager.shared.deleteMessageForAll(chatId: chatId, messageId: messageId)
                                              }
                                          }
                                       Button("Cancel", role: .cancel) { }
                                   } message: {
                                       Text("Are you sure you want to delete this message?")
                                   }
                                   .confirmationDialog("Delete message", isPresented: $showDeleteMessageDialog2) {
                                       Button("Delete message", role: .destructive) {
                                           if let messageId = messageIdToDelete,  let chatId = chatId  {
                                               MessageManager.shared.hideMessageForOne(chatId: chatId, messageId: messageId)
                                           }
                                       }
                                       Button("Cancel", role: .cancel) { }
                                   } message: {
                                       Text("Are you sure you want to delete this message?")
                                   }
                            .onAppear {
                                viewModel.scrollToBottom += 1
                                showTabBar = false
                                setupChatMessages()
                                if let lastMessageId = messagesListener.messages.last?.messageId {
                                    proxy.scrollTo(lastMessageId, anchor: .bottom)
                                    //   scrollToBottom += 1
                                    
                                }
                            }
                            .onDisappear {
                                showTabBar = true
                                messagesListener.stopListening()
                            }
                            .safeAreaInset(edge: .top) {
                                topBar(chat: chat)
                            }
                            .safeAreaInset(edge: .bottom) {
                                bottomBar()
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .task {
                await initializeChat()
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
    
    private func setupPreviewData() {
        viewModel.chatModel = ChatModel(id: "MxzozNOYwoewogj9mlBqsuKPRjg2_NZdovIB5X2gezRIOwMunlLSwK1I2",
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
        messagesListener.messages = [
            MessageModel(messageId: "1",
                         senderId: "MxzozNOYwoewogj9mlBqsuKPRjg2",
                         message: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/Chat%2FNZdovIB5X2gezRIOwMunlLSwK1I2_nCPFtvU1sQUF6jIVVZ5opL3nPw62%2Fmessages%2FF61A719B-7BCE-4AD7-8782-D6930A919F3C.mp3?alt=media&token=31ada8ae-304b-4dd0-a3a4-11c344e16c53",
                         isPhoto: false,
                         isAudio: true,
                         sentAt: Timestamp(date: Date()),
                         firstDeleteId: "",
                         secondDeleteId: "",
                         isDeletedForAll: false),
            MessageModel(messageId: "2",
                         senderId: "currentUid",
                         message: "https://i0.wp.com/picjumbo.com/wp-content/uploads/camping-on-top-of-the-mountain-during-sunset-free-photo.jpg?w=600&quality=80",
                         isPhoto: true,
                         isAudio: false,
                         sentAt: Timestamp(date: Date()),
                         firstDeleteId: "",
                         secondDeleteId: "",
                         isDeletedForAll: false),
            MessageModel(messageId: "3",
                         senderId: "currentUid",
                         message: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/Chat%2FNZdovIB5X2gezRIOwMunlLSwK1I2_nCPFtvU1sQUF6jIVVZ5opL3nPw62%2Fmessages%2FF61A719B-7BCE-4AD7-8782-D6930A919F3C.mp3?alt=media&token=31ada8ae-304b-4dd0-a3a4-11c344e16c53",
                         isPhoto: false,
                         isAudio: true,
                         sentAt: Timestamp(date: Date()),
                         firstDeleteId: "",
                         secondDeleteId: "",
                         isDeletedForAll: true),
            MessageModel(messageId: "4",
                         senderId: "currentUid",
                         message: "https://th.bing.com/th/id/R.bdf7ba9a5d361bc463e70e6ee8f7a1da?rik=FIlX39ntHMLKjg&riu=http%3a%2f%2froneradionowindy.files.wordpress.com%2f2017%2f11%2f15100028051007.jpg%3fquality%3d80%26strip%3dall%26strip%3dall&ehk=EO3jUZUXQStOI7ATday8O9dhgon%2blT%2f7RMz0IJA%2f1Bo%3d&risl=&pid=ImgRaw&r=0",
                         isPhoto: true,
                         isAudio: false,
                         sentAt: Timestamp(date: Date()),
                         firstDeleteId: "",
                         secondDeleteId: "",
                         isDeletedForAll: false)
        ]
    }
    
    private func setupChatMessages() {
        if isPreview {
            setupPreviewData()
        } else {
            guard let chatIdNotNil = chatId else {
                print("chatId is nil")
                return
            }
            guard let contactIdNotNil = contactId else {
                print("contactId is nil")
                return
            }
            if contactIdNotNil.isEmpty {
                if !chatIdNotNil.isEmpty {
                    
                    messagesListener.startListening(chatId: chatIdNotNil)
                    MessageManager.markLastMessageAsRead(chatId: chatIdNotNil, currentUid: currentUid)
                    DispatchQueue.main.async {
                        viewModel.scrollToBottom += 1
                    }
                }
            } else {
                if !contactIdNotNil.isEmpty {
                    viewModel.isLoading = true
                    Task {
                        var chatIdViewModel: String? = nil
                        while chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                            chatIdViewModel = await viewModel.verifyChatExistenceForString(secondUid: contactIdNotNil)
                            if chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                                try await Task.sleep(nanoseconds: 500_000_000)
                            }
                        }
                        viewModel.isLoading = false
                        messagesListener.startListening(chatId: chatIdViewModel ?? "")
                        //                        if !currentUid {
                        MessageManager.markLastMessageAsRead(chatId: chatIdViewModel ?? "", currentUid: currentUid)
                        //                        }
                        DispatchQueue.main.async {
                            viewModel.scrollToBottom += 1
                        }
                    }
                }
            }
        }
    }
    
    private func initializeChat() async {
        if isPreview {
            setupPreviewData()
        } else {
            guard let chatIdNotNil = chatId else { return }
            guard let contactIdNotNil = contactId else { return }
            if contactIdNotNil.isEmpty {
                if !chatIdNotNil.isEmpty {
                    await viewModel.fetchChat(id: chatIdNotNil)
                }
            } else {
                if !contactIdNotNil.isEmpty {
                    viewModel.isLoading = true
                    Task {
                        var chatIdViewModel: String? = nil
                        while chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                            chatIdViewModel = await viewModel.verifyChatExistenceForString(secondUid: contactIdNotNil)
                            if chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                                try await Task.sleep(nanoseconds: 500_000_000)
                            }
                        }
                        viewModel.isLoading = false
                        await viewModel.fetchChat(id: chatIdViewModel ?? "")
                    }
                }
            }
        }
    }
    
    private func topBar(chat: ChatModel) -> some View {
        VStack(alignment: .leading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .padding(.horizontal)
            HStack {
                ZStack {
//                    NavigationLink {
//                        //     Text("Details about user")
//                    } label: { EmptyView() }
                    Button { viewModel.showDetailsView.toggle()
                    } label: {
                        HStack {
                            if chat.firstUid == currentUid {
                                if let profilePhotoURL = chat.secondProfilePicture {
                                    AsyncImage(url: URL(string: profilePhotoURL)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fit).clipShape(Circle()).frame(width: 70, height: 70)
                                        case .empty:
                                            ProgressView().frame(width: 70, height: 70)
                                        default:
                                            Image(systemName: "person.circle").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                                        }
                                    }
                                }
                                VStack(alignment: .leading) {
                                    let name = "\(chat.secondName)"
                                    // let status = userStatus == "online" ? "Online" : "Offline"
                                    Text(name).font(.title2.bold())
                                    if let status = messagesListener.userStatuses[chat.secondUid] {
                                        HStack(spacing: 2.0) {
                                            Image(systemName: "circle.fill")
                                            Text(status == "online" ? "Online" : "Offline")
                                        }
                                        .font(.caption.bold())
                                        .foregroundStyle(status == "online" ? .green : .gray)
                                    }
                                }
                            } else {
                                if let profilePhotoURL = chat.firstProfilePicture {
                                    AsyncImage(url: URL(string: profilePhotoURL)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fit).clipShape(Circle()).frame(width: 70, height: 70)
                                        case .empty:
                                            ProgressView().frame(width: 70, height: 70)
                                        default:
                                            Image(systemName: "person.circle").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                                        }
                                    }
                                }
                                VStack(alignment: .leading) {
                                    let name = "\(chat.firstName)"
                                    // let status = userStatus == "online" ? "Online" : "Offline"
                                    Text(name).font(.title2.bold())
                                    if let status = messagesListener.userStatuses[chat.firstUid] {
                                        HStack(spacing: 2.0) {
                                            Image(systemName: "circle.fill")
                                            Text(status == "online" ? "Online" : "Offline")
                                        }
                                        .font(.caption.bold())
                                        .foregroundStyle(status == "online" ? .green : .gray)
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
                HStack(spacing: 30.0) {
                    ZStack {
                        Button(action: {
                            if currentUid == chat.firstUid {
                                userId = chat.firstUid
                                secondId = chat.secondUid
                                token = chat.firstToken
                                firstPhoto = chat.firstProfilePicture ?? ""
                                secondPhoto = chat.secondProfilePicture ?? ""
                                userName = chat.secondName
                                if !messagesListener.audioCallExists {
                                    CallManager.shared.createCall(receiverId: chat.secondUid, isVideo: false)
                                }
                            } else {
                                userId = chat.secondUid
                                secondId = chat.firstUid
                                token = chat.secondToken
                                firstPhoto = chat.secondProfilePicture ?? ""
                                secondPhoto = chat.firstProfilePicture ?? ""
                                userName = chat.firstName
                                if !messagesListener.audioCallExists {
                                    CallManager.shared.createCall(receiverId: chat.firstUid, isVideo: false)
                                }
                            }
                            callType = .audio
                            isCalling.toggle()
                        }) {
                            Image(systemName: messagesListener.audioCallExists ? "phone.badge.waveform" : "phone")
                                .foregroundStyle(messagesListener.audioCallExists ? .green : .primary)
                                .font(messagesListener.audioCallExists ? .body.bold() : .body)
                        }
                        .hidden(messagesListener.videoCallExists)
                    }
                    
                    ZStack {
                        Button(action: {
                            if currentUid == chat.firstUid {
                                userId = chat.firstUid
                                secondId = chat.secondUid
                                token = chat.firstToken
                                firstPhoto = chat.firstProfilePicture ?? ""
                                secondPhoto = chat.secondProfilePicture ?? ""
                                userName = chat.secondName
                                if (!messagesListener.videoCallExists) {
                                    CallManager.shared.createCall(receiverId: chat.secondUid, isVideo: true)
                                }
                            } else {
                                userId = chat.secondUid
                                secondId = chat.firstUid
                                token = chat.secondToken
                                firstPhoto = chat.secondProfilePicture ?? ""
                                secondPhoto = chat.firstProfilePicture ?? ""
                                userName = chat.firstName
                                if (!messagesListener.videoCallExists) {
                                    CallManager.shared.createCall(receiverId: chat.firstUid, isVideo: true)
                                }
                            }
                            callType = .video
                            isCalling.toggle()
                        }) {
                            Image(systemName: messagesListener.videoCallExists ? "video.badge.waveform" : "video")
                                .foregroundStyle(messagesListener.videoCallExists ? .green : .primary)
                                .font(messagesListener.videoCallExists ? .body.bold() : .body)
                        }
                        .hidden(messagesListener.audioCallExists)
                    }
                }
                .fullScreenCover(isPresented: $isCalling) {
                    if let callType = callType {
                        CallContainerSetup(
                            callId: chat.callId,
                            userId: userId ?? "",
                            secondUid: secondId ?? "",
                            token: token ?? "",
                            chatId: chat.id,
                            isVideoCall: callType == .video,
                            firstPhoto: firstPhoto ?? "",
                            secondPhoto: secondPhoto ?? "",
                            userName: userName ?? ""
                        )
                    } else {
                        EmptyView()
                    }
                }
                .font(.title3)
            }
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $viewModel.showDetailsView) {
            SheetDetailsChat(chatId: $chatId, contactId: $contactId)
        }
        .background(.ultraThinMaterial)
    }
    
    private func bottomBar() -> some View {
        HStack(alignment: .bottom, spacing: 0.0) {
            Button { viewModel.showPopover.toggle() } label: {
                Image(systemName: "plus").frame(width: 40, height: 40)
            }
            .popover(isPresented: $viewModel.showPopover) {
                HStack {
                    Button {
                    } label: {
                        PhotosPicker(selection: $viewModel.photoPickerItem, matching: .images) {
                            Image(systemName: "photo.badge.plus")
                        }
                        .onChange(of: viewModel.photoPickerItem) {
                            if let photoPickerItem = viewModel.photoPickerItem {
                                Task {
                                    if let data = try? await photoPickerItem.loadTransferable(type: Data.self) {
                                        sendMessageWithImage(imageData: data)
                                        viewModel.showPopover.toggle()
                                    }
                                }
                            }
                        }
                    }
                    Divider()
                    Button {
                        self.showCamera.toggle()
                    } label: { Image(systemName: "camera") }
                        .fullScreenCover(isPresented: self.$showCamera) {
                            AccessCamera(selectedImage: self.$selectedImage) { imageData in
                                sendMessageWithImage(imageData: imageData)
                                viewModel.showPopover.toggle()
                            }}
                    Divider()
                    Button {
                        toggleAudioRecording()
                    } label: {
                        HStack {
                            if !voiceRecorder.isRecording {
                                Image(systemName: "mic.circle")
                                    .font(.title3)
                            } else {
                                Image(systemName: "stop.circle")
                                    .foregroundStyle(.red)
                                    .font(.title3)
                                Spacer()
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundStyle(.red)
                                        .font(.caption)
                                       withAnimation {
                                    Text(voiceRecorder.elapsedTime.formatElapsedTime)
                                        .font(.body)
                                        .foregroundColor(.red)
                                     .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                                     }
                                }
                                .frame(width: 100)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .presentationCompactAdaptation(.popover)
            }
            TextField("type..", text: $viewModel.message, axis: .vertical)
                .lineLimit(1...10)
                .padding(.leading, 8)
                .padding(.trailing, 8)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(.thinMaterial))
                .submitLabel(.send)
            HStack {
                Button {
                    guard let chatIdNotNil = chatId else {
                        print("chatId is nil")
                        return
                    }
                    guard let contactIdNotNil = contactId else {
                        print("contactId is nil")
                        return
                    }
                    
                    if contactIdNotNil.isEmpty {
                        if !chatIdNotNil.isEmpty {
                            Task {
                                do {
                                    let receiver =  await MessageManager.shared.verifyOtherParticipantUid(chatID: chatIdNotNil)
                                    print("receiver ul ar trebui sa fie \(receiver ?? "nu stiu ce s a intamplat")")
                                    let key = try await MessageManager.shared.fetchKey(chatId: chatIdNotNil)
                                    MessageManager.shared.sendMessage(chatId: chatIdNotNil, message: viewModel.message, isPhoto: false, isAudio: false, key: key)
                                    MessageManager.shared.updateChat(chatId: chatIdNotNil, isLastMessageRead: false, receiverUid: receiver ?? "", isPhoto: false, isAudio: false)
                                    viewModel.message = ""
                                    DispatchQueue.main.async {
                                        viewModel.scrollToBottom += 1
                                    }
                                }
                            }
                        }
                    } else {
                        if !contactIdNotNil.isEmpty {
                            Task {
                                var chatIdViewModel: String? = nil
                                while chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                                    chatIdViewModel = await viewModel.verifyChatExistenceForString(secondUid: contactIdNotNil)
                                    if chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                                        try await Task.sleep(nanoseconds: 500_000_000)
                                    }
                                }
                                
                                guard let validChatId = chatIdViewModel, !validChatId.isEmpty else {
                                    print("Failed to get valid chatId")
                                    return
                                }
                                
                                do {
                                    let receiver = await MessageManager.shared.verifyOtherParticipantUid(chatID: validChatId)
                                    print("receiver ul ar trebui sa fie \(receiver ?? "nu stiu ce s-a intamplat")")
                                    let key = try await MessageManager.shared.fetchKey(chatId: validChatId)
                                    MessageManager.shared.sendMessage(chatId: validChatId, message: viewModel.message, isPhoto: false, isAudio: false, key: key)
                                    MessageManager.shared.updateChat(chatId: validChatId, isLastMessageRead: false, receiverUid: receiver ?? "", isPhoto: false, isAudio: false)
                                    viewModel.message = ""
                                    DispatchQueue.main.async {
                                        viewModel.scrollToBottom += 1
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "paperplane").frame(width: 40, height: 40)
                }
                .disabled(viewModel.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .bottom)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
    }
    
    func sendMessageWithImage(imageData: Data) {
        guard let chatIdNotNil = chatId else {
            print("chatId is nil")
            return
        }
        guard let contactIdNotNil = contactId else {
            print("contactId is nil")
            return
        }
        
        if contactIdNotNil.isEmpty {
            if !chatIdNotNil.isEmpty {
                Task {
                    do {
                        let receiver =  await MessageManager.shared.verifyOtherParticipantUid(chatID: chatIdNotNil)
                        print("receiver ul ar trebui sa fie \(receiver ?? "nu stiu ce s a intamplat")")
                        let key = try await MessageManager.shared.fetchKey(chatId: chatIdNotNil)
                        MessageManager.shared.sendMessage(chatId: chatIdNotNil, message: "", isPhoto: true, isAudio: false, imageData: imageData, key: key)
                        MessageManager.shared.updateChat(chatId: chatIdNotNil, isLastMessageRead: false, receiverUid: receiver ?? "", isPhoto: true, isAudio: false)
                        viewModel.message = ""
                        DispatchQueue.main.async {
                            viewModel.scrollToBottom += 1
                        }
                    }
                }
            }
        } else {
            if !contactIdNotNil.isEmpty {
                Task {
                    var chatIdViewModel: String? = nil
                    while chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                        chatIdViewModel = await viewModel.verifyChatExistenceForString(secondUid: contactIdNotNil)
                        if chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                            try await Task.sleep(nanoseconds: 500_000_000)
                        }
                    }
                    
                    guard let validChatId = chatIdViewModel, !validChatId.isEmpty else {
                        print("Failed to get valid chatId")
                        return
                    }
                    
                    do {
                        let receiver = await MessageManager.shared.verifyOtherParticipantUid(chatID: validChatId)
                        print("receiver ul ar trebui sa fie \(receiver ?? "nu stiu ce s-a intamplat")")
                        let key = try await MessageManager.shared.fetchKey(chatId: validChatId)
                        MessageManager.shared.sendMessage(chatId: validChatId, message: "", isPhoto: true, isAudio: false, imageData: imageData, key: key)
                        MessageManager.shared.updateChat(chatId: validChatId, isLastMessageRead: false, receiverUid: receiver ?? "", isPhoto: true, isAudio: false)
                        viewModel.message = ""
                        DispatchQueue.main.async {
                            viewModel.scrollToBottom += 1
                        }
                    }
                }
            }
        }
    }
    func toggleAudioRecording() {
         if voiceRecorder.isRecording {
             voiceRecorder.stopRecording { url, duration in
                 viewModel.showPopover.toggle()
                 if let url = url {
                     do {
                         let audioData = try Data(contentsOf: url)
                         viewModel.sendMessageWithAudio(audioData: audioData, chatId: chatId, contactId: contactId)
                     } catch {
                         print("Error getting audio data: \(error.localizedDescription)")
                     }
                 }
             }
         } else {
             voiceRecorder.startRecording()
         }
     }
}




        struct ChatView_Previews: PreviewProvider {
            static var previews: some View {
                ChatView(showTabBar: .constant(true), chatId: "chatId", contactId: "", callId: "", userId: "", token: "", isVideoCall: false)
                    .environment(\.isPreview, true)
            }
        }

    
