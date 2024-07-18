//
//  CallControlsView.swift
//  Licenta
//
//  Created by Georgiana Costea on 16.06.2024.
//

import SwiftUI
import StreamVideoSwiftUI

struct CallControlsView: View {

    @ObservedObject var viewModel: CallViewModel
    @State private var isVideo = true
    @State private var isAudio = true
    @State private var isFront = true
    @State private var endCall = false

    var body: some View {
       floatingBar()
    }
    
    func floatingBar()  -> some View {
        HStack(spacing: 32) {
            Button {
                viewModel.toggleCameraEnabled()
                isVideo.toggle()
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
                viewModel.toggleMicrophoneEnabled()
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
                viewModel.toggleCameraPosition()
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
            
            Button {
                Task {
                    try await viewModel.call?.end()
                }
                endCall.toggle()
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "xmark")
                        .frame(height: 48)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 48)
        }
        .padding(.bottom)
    }
}
