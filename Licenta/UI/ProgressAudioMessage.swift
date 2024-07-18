//
//  ProgressMessageAudio.swift
//  Licenta
//
//  Created by Georgiana Costea on 12.06.2024.
//

import SwiftUI
import AVFoundation
import Firebase

struct ProgressAudioMessage: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var isPlaying = false
    @State private var progress: Double = 0.0
    @State private var remainingTime: TimeInterval = 0.0
    
    var message: MessageModel

    var body: some View {
        HStack {
            Button(action: {
                if isPlaying {
                    viewModel.audioPlayer?.pause()
                    isPlaying = false
                } else {
                    Task {
                        do {
                            try await viewModel.playAudio(message: message)
                            isPlaying = true
                            startTimer()
                        } catch {
                            print("Error playing audio: \(error.localizedDescription)")
                        }
                    }
                }
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .font(.title)
            }
            
            ProgressBar(value: $progress)
                .frame(height: 10)
                .padding(.horizontal, 10)
            
            Text("\(formatTime(remainingTime))")
                .font(.caption)
                .foregroundStyle(Color(.label))
        }
        .onReceive(viewModel.$audioPlayer) { player in
            guard let player = player else { return }
            self.remainingTime = player.duration - player.currentTime
            if player.isPlaying {
                startTimer()
            }
        }
        .onAppear {
            Task {
                await viewModel.prepareAudio(message: message)
                if let player = viewModel.audioPlayer {
                    self.remainingTime = player.duration
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard let player = viewModel.audioPlayer else {
                timer.invalidate()
                return
            }
            if player.isPlaying {
                self.progress = player.currentTime / player.duration
                self.remainingTime = player.duration - player.currentTime
            } else {
                timer.invalidate()
                if self.remainingTime <= 0 {
                    self.isPlaying = false
                }
            }
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
            self.isPlaying = false
            self.progress = 0.0
            self.remainingTime = viewModel.audioPlayer?.duration ?? 0.0
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ProgressBar: View {
    @Binding var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundStyle(Color(.label))
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.circle1)
                    .animation(.linear, value: value)
            }
            .cornerRadius(45.0)
        }
    }
}

#Preview {
    ProgressAudioMessage(message:  MessageModel(messageId: "1",
                                                senderId: "MxzozNOYwoewogj9mlBqsuKPRjg2",
                                                message: "https://firebasestorage.googleapis.com:443/v0/b/licenta-ee87a.appspot.com/o/Chat%2FNZdovIB5X2gezRIOwMunlLSwK1I2_nCPFtvU1sQUF6jIVVZ5opL3nPw62%2Fmessages%2FF61A719B-7BCE-4AD7-8782-D6930A919F3C.mp3?alt=media&token=31ada8ae-304b-4dd0-a3a4-11c344e16c53",
                                                isPhoto: false,
                                                isAudio: true,
                                                sentAt: Timestamp(date: Date()),
                                               firstDeleteId: "",
                                               secondDeleteId: "",
                                               isDeletedForAll: false))
}
