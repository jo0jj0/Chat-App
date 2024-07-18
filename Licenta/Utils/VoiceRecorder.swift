//
//  VoiceRecorder.swift
//  Licenta
//
//  Created by Georgiana Costea on 20.06.2024.
//

import Foundation
import AVFoundation
import Combine

final class VoiceRecorder: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
  @Published  var isRecording: Bool = false
    private var startTimer: Date?
    private var timer: AnyCancellable?
    @Published var elapsedTime: TimeInterval = 0
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFile = Date().toString(format: "dd-MM-YY 'at' HH:mm:ss") + ".m4a"
        let audioFileUrl = documentPath.appendingPathComponent(audioFile)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileUrl, settings: settings)
            audioRecorder?.record()
            isRecording = true
            startTimer = Date()
            startingTimer()
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }
    
    private func startingTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let startTimer = self?.startTimer else { return }
                self?.elapsedTime = Date().timeIntervalSince(startTimer)
            }
    }
    
    func stopRecording(completion: ((_ audioUrl: URL?, _ audioTime: TimeInterval) -> Void)? = nil) {
        guard isRecording else { return }
        let audioTime = elapsedTime
        audioRecorder?.stop()
        isRecording = false
        timer?.cancel()
        elapsedTime = 0
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            guard let audioUrl = audioRecorder?.url else { return }
            completion?(audioUrl, audioTime)
            try audioSession.setActive(true)
        } catch {
            print("Error for stop recording: \(error.localizedDescription)")
        }
    }
    
    func deleteLocalAudio() {
        let fileManager = FileManager.default
        let folder = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        _ = try! fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        print("audio deleted")
    }
}
   
