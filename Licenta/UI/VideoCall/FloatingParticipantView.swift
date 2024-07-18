//
//  FloatingParticipanteView.swift
//  Licenta
//
//  Created by Georgiana Costea on 16.06.2024.
//

import Foundation
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct FloatingParticipantView: View {

    var participant: CallParticipant?
    var size: CGSize = .init(width: 140, height: 180)
    var isVideoEnabled: Bool

    var body: some View {
        if let participant = participant {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        if isVideoEnabled {
                            VideoRendererView(id: participant.id, size: size) { videoRenderer in
                                videoRenderer.handleViewRendering(for: participant, onTrackSizeUpdate: { _, _ in })
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .frame(width: size.width, height: size.height)
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
}
