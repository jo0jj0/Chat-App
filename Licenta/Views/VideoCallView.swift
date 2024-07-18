//
//  VideoCallView.swift
//  Licenta
//
//  Created by Georgiana Costea on 16.06.2024.
//

//import SwiftUI
//import StreamVideo
//import StreamVideoSwiftUI
//
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI


//public struct WaitingLocalUserView<Factory: ViewFactory>: View {
//
//    @Injected(\.appearance) var appearance
//
//    @ObservedObject var viewModel: CallViewModel
//    var viewFactory: Factory
//    
//    public init(viewModel: CallViewModel, viewFactory: Factory) {
//        self.viewModel = viewModel
//        self.viewFactory = viewFactory
//    }
//    
//    public var body: some View {
//        ZStack {
////            DefaultBackgroundGradient()
////                .edgesIgnoringSafeArea(.all)
//
//            VStack {
//                // Eliminarea butonului din partea de sus care este pentru rotirea camerei
//                // viewFactory.makeCallTopView(viewModel: viewModel)
//                //    .opacity(viewModel.callingState == .reconnecting ? 0 : 1)
//
//                Group {
//                    if let localParticipant = viewModel.localParticipant {
//                        GeometryReader { proxy in
//                            LocalVideoView(
//                                viewFactory: viewFactory,
//                                participant: localParticipant,
//                                idSuffix: "waiting",
//                                callSettings: viewModel.callSettings,
//                                call: viewModel.call,
//                                availableFrame: proxy.frame(in: .global)
//                            )
//                            .modifier(viewFactory.makeLocalParticipantViewModifier(
//                                localParticipant: localParticipant,
//                                callSettings: $viewModel.callSettings,
//                                call: viewModel.call
//                            ))
//                            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ocupă tot ecranul
//                        }
//                    } else {
//                        Spacer()
//                    }
//                }
//                .padding(.horizontal, 8)
//                .opacity(viewModel.callingState == .reconnecting ? 0 : 1)
//
//                // Mutarea butonului de terminare a apelului lângă celelalte trei butoane
//                HStack {
//                    viewFactory.makeCallControlsView(viewModel: viewModel)
//                    viewFactory.makeEndCallButton(viewModel: viewModel) // Aici ne asigurăm că avem un factory pentru butonul de terminare
//                }
//                .opacity(viewModel.callingState == .reconnecting ? 0 : 1)
//            }
//            .presentParticipantListView(viewModel: viewModel, viewFactory: viewFactory)
//        }
//    }
//}
//

//
//struct VideoCallView: View {
//    
//    @ObservedObject var viewModel: CallViewModel
//    
//    @Binding var showTabBar: Bool
//
//    @State var call: Call
//    @ObservedObject var state: CallState
//    @State var callCreated: Bool = false
//    
//    private var client: StreamVideo
//    
//    private let apiKey: String = "mmhfdzb5evj2" // The API key can be found in the Credentials section
//    private let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiSmVyZWMiLCJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0plcmVjIiwiaWF0IjoxNzE4NTU1NjgwLCJleHAiOjE3MTkxNjA0ODV9.zSMrlXIiHF-ndM6Zs52dSyWH3EK3PJo60-50SKJlFvw" // The Token can be found in the Credentials section
//    private let userId: String = "Jerec" // The User Id can be found in the Credentials section
//    private let callId: String = "FxXqbCUkL2xG" // The CallId can be found in the Credentials section
//    
//    init(showTabBar: Binding<Bool>) {
//        let user = User(
//            id: userId,
//            name: "Martin", // name and imageURL are used in the UI
//            imageURL: .init(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/a3911/martin-mitrevski.webp")
//        )
//        
//        // Initialize Stream Video client
//        self.client = StreamVideo(
//            apiKey: apiKey,
//            user: user,
//            token: .init(stringLiteral: token)
//        )
//        self.viewModel = .init()
//        
//        // Initialize the call object
//        let call = client.call(callType: "default", callId: callId)
//
//        self.call = call
//        self.state = call.state
//        
//        self._showTabBar = showTabBar
//    }
//
//    var body: some View {
//        VStack {
//            if let call = viewModel.call {
//                CallContainer(viewFactory: DefaultViewFactory.shared, viewModel: viewModel)
//            } else {
//                Text("loading...")
//            }
//        }
//        .onAppear {
//            showTabBar = false
//            Task {
//                guard viewModel.call == nil else { return }
//                viewModel.joinCall(callType: .default, callId: callId)
//            }
//        }
//    }
//
//    private func changeTrackVisibility(_ participant: CallParticipant?, isVisible: Bool) {
//        guard let participant else { return }
//        Task {
//            await call.changeTrackVisibility(for: participant, isVisible: isVisible)
//        }
//    }
//}
//

//struct ParticipantsView: View {
//
//    @Binding var showTabBar: Bool
//
//    var call: Call
//    var participants: [CallParticipant]
//    var onChangeTrackVisibility: (CallParticipant?, Bool) -> Void
//
//    var body: some View {
//        ZStack {
//            GeometryReader { proxy in
//                if !participants.isEmpty {
//                    ScrollView {
//                        LazyVStack {
//                            if participants.count == 1, let participant = participants.first {
//                                makeCallParticipantView(participant, frame: proxy.frame(in: .global))
//                                    .frame(width: proxy.size.width, height: proxy.size.height)
//                            } else {
//                                ForEach(participants) { participant in
//                                    makeCallParticipantView(participant, frame: proxy.frame(in: .global))
//                                        .frame(width: proxy.size.width, height: proxy.size.height / 2)
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    Color.black
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//
//    @ViewBuilder
//    private func makeCallParticipantView(_ participant: CallParticipant, frame: CGRect) -> some View {
//        VideoCallParticipantView(
//            participant: participant,
//            availableFrame: frame,
//            contentMode: .scaleAspectFit,
//            customData: [:],
//            call: call
//        )
//        .onAppear { onChangeTrackVisibility(participant, true) }
//        .onDisappear{ onChangeTrackVisibility(participant, false) }
//    }
//}

//struct FloatingParticipantView: View {
//
//    var participant: CallParticipant?
//    var size: CGSize = .init(width: 120, height: 120)
//
//    var body: some View {
//        if let participant = participant {
//            VStack {
//                HStack {
//                    Spacer()
//
//                    VideoRendererView(id: participant.id, size: size) { videoRenderer in
//                        videoRenderer.handleViewRendering(for: participant, onTrackSizeUpdate: { _, _ in })
//                    }
//                    .frame(width: size.width, height: size.height)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                }
//                Spacer()
//            }
//            .padding()
//        }
//    }
//}

