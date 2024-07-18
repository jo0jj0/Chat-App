//
//  CallContainerSetup.swift
//  Licenta
//
//  Created by Georgiana Costea on 16.06.2024.
//

import Foundation
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct CallContainerSetup: View {
    @StateObject var listener = CallListener()
    @StateObject var listenerClose = ClosedCallListener()
    @ObservedObject var viewModel: CallViewModel
    @ObservedObject var state: CallState
    @State var callCreated: Bool = false
    @State private var isAudio = true
    @State private var isFront = true
    @State private var endCall = false
    @State private var callDuration: Int = 0
    @State private var timer: Timer? = nil
    @State private var shouldNavigateToChatView = false
    @Environment(\.dismiss) private var dismiss

    
    let callId: String
    let userId: String
    let secondUid: String
    let token: String
    let chatId: String
    let isVideoCall: Bool
    let firstPhoto: String
    let secondPhoto: String
    let userName: String
    @State var call: Call
    @State var callDocumentId: String
    @State private var isVideo: Bool

    private var client: StreamVideo
    private let apiKey: String = "xcz93p3wmgrq"
    
    init(
        callId: String,
        userId: String,
        secondUid: String,
        token: String,
        chatId: String,
        isVideoCall: Bool,
        firstPhoto: String,
        secondPhoto: String,
        userName: String
    ) {
        self.callId = callId
        self.userId = userId
        self.secondUid = secondUid
        self.token = token
        self.chatId = chatId
        self.isVideoCall = isVideoCall
        self.firstPhoto = firstPhoto
        self.secondPhoto = secondPhoto
        self.userName = userName
        
        let user = User(id: userId)
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )
        
        self.viewModel = CallViewModel()
        let call = client.call(callType: "default", callId: callId)
        self.call = call
        
        self._state = ObservedObject(wrappedValue: call.state)
        self.callDocumentId = ""
        self.isVideo = isVideoCall
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if callCreated {
                    ZStack {
                            ParticipantsView(
                                call: call,
                                state: state,
                                onChangeTrackVisibility: { participant, isVisible in
                                    changeTrackVisibility(participant, isVisible: isVisible)
                                },
                                participantPhoto: secondPhoto
                            )
                    }
                    .overlay(alignment: .topTrailing) {
                        ZStack {
                            if isVideo {
                                FloatingParticipantView(participant: state.localParticipant, isVideoEnabled: isVideo)
                            } else {
                                LocalParticipantVideoOff(profilePicture: firstPhoto)
                            }
                        }
                        .padding()
                        .padding(.top, 50)
                    }
                    floatingBar(call: call)
                } else {
                    Text("Loading...")
                }
            }
            .alert("Call has ended.", isPresented: $listener.showAlert) {
                Button("OK", role: .cancel) {
                    call.leave()
                    dismiss()
                }
            } message: {
                    Text("Go back to the chat.")
            }
            .ignoresSafeArea()
            .onAppear {
                Task {
                    guard callCreated == false else { return }
                    try await call.join(create: true)
                    callDocumentId = await CallManager.shared.getCallId() ?? ""
                    callCreated = true
                    startCallTimer()
                    listener.startListenerForCurrentUser(callId: callDocumentId)
                    if isVideoCall {
                        try await call.camera.enable()
                        isVideo = true
                    } else {
                        try await call.camera.disable()
                        isVideo = false
                    }
                }
            }
            .onDisappear {
                stopCallTimer()
                listener.stopListeningCurrentUser()
            }
        }
        .safeAreaInset(edge: .top) {
            Text(userName)
                .font(.title2).bold()
        }
    }
    
    private func startCallTimer() {
        callDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            callDuration += 1
        }
    }
    
    private func stopCallTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func floatingBar(call: Call) -> some View {
        HStack(spacing: 32) {
            Button {
                Task {
                    if isVideo {
                        try await call.camera.disable()
                        isVideo = false
                    } else {
                        try await call.camera.enable()
                        isVideo = true
                    }
                }
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: isVideo ? "video.fill" : "video.slash.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .frame(height: 48)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 54)
            
            Button {
                if isAudio {
                    Task {
                        try await call.microphone.disable()
                    }
                } else {
                    Task {
                        try await call.microphone.enable()
                    }
                }
                isAudio.toggle()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: isAudio ? "mic.fill" : "mic.slash.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .frame(height: 48)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 48)
            
            Button {
                Task {
                    try await call.camera.flip()
                }
                isFront.toggle()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: isFront ? "camera.on.rectangle.fill" : "camera.metering.matrix")
                        .contentTransition(.interpolate)
                        .frame(height: 48)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 48)
            
            ZStack {
                Button {
                    endCallProcess()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "phone.down.fill")
                            .padding()
                            .background(Circle().fill(.red))
                            .frame(height: 48)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 48)
                NavigationLink {
                    ChatView(showTabBar: .constant(false), chatId: chatId, contactId: "")
                } label: {
                    EmptyView()
                }
                .frame(width: 0)
                .opacity(0)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay() {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
        }
        .padding(.bottom, 80)
    }
    
    private func endCallProcess() {
        Task {
            do {
                call.leave()
                CallManager.shared.updateCall(callId: callDocumentId, duration: callDuration)
                listener.stopListeningCurrentUser()
                dismiss()
            }
        }
    }
    
    private func changeTrackVisibility(_ participant: CallParticipant?, isVisible: Bool) {
        guard let participant else { return }
        Task {
            await call.changeTrackVisibility(for: participant, isVisible: isVisible)
        }
    }
}
