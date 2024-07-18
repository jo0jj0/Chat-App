//
//  ParticipantsView.swift
//  Licenta
//
//  Created by Georgiana Costea on 16.06.2024.
//

import Foundation
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct ParticipantsView: View {

    var call: Call
    @ObservedObject var state: CallState
    var onChangeTrackVisibility: (CallParticipant?, Bool) -> Void
    var participantPhoto: String
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(state.remoteParticipants) { participant in
                        makeCallParticipantView(participant, frame: proxy.frame(in: .global), participantPhoto: participantPhoto)
                            .frame(width: proxy.size.width, height: proxy.size.height / CGFloat(state.remoteParticipants.count))
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    @ViewBuilder
    private func makeCallParticipantView(_ participant: CallParticipant, frame: CGRect, participantPhoto: String) -> some View {
        if participant.hasVideo {
            VideoCallParticipantView(
                participant: participant,
                availableFrame: frame,
                contentMode: .scaleAspectFit,
                customData: [:],
                call: call
            )
            .onAppear { onChangeTrackVisibility(participant, true) }
        } else {
            OtherParticipantVideoOff(profilePicture: participantPhoto) // Assuming profilePhoto is available
        }
    }
}
