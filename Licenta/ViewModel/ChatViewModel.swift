//
//  ChatViewModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 11.06.2024.
//

import Foundation
import PhotosUI
import AVFoundation
import SwiftUI
import Firebase

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var chatModel: ChatModel?
    @Published var message: String =  ""
    @Published var showDetailsView: Bool = false
    @Published var showPopover: Bool = false
    @Published var showMessagePopover: Bool = false
    @Published var isLoading: Bool = false
    @Published var scrollToBottom = 0
    @Published var photoPickerItem: PhotosPickerItem?
    @Published var recordingTime: TimeInterval = 0
    @Published var selectedImageURL: String?
    @Published var showImageViewer = false
    @Published var audioPlayer: AVAudioPlayer?

    
    func sendMessageWithAudio(audioData: Data, chatId: String?, contactId: String?) {
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
                        MessageManager.shared.sendMessage(chatId: chatIdNotNil, message: "", isPhoto: false, isAudio: true, audioData: audioData, key: key)
                        MessageManager.shared.updateChat(chatId: chatIdNotNil, isLastMessageRead: false, receiverUid: receiver ?? "", isPhoto: false, isAudio: true)
                        message = ""
                        DispatchQueue.main.async {
                            self.scrollToBottom += 1
                        }
                    }
                }
            }
        } else {
            if !contactIdNotNil.isEmpty {
                Task {
                    var chatIdViewModel: String? = nil
                    while chatIdViewModel == nil || chatIdViewModel!.isEmpty {
                        chatIdViewModel = await verifyChatExistenceForString(secondUid: contactIdNotNil)
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
                        MessageManager.shared.sendMessage(chatId: validChatId, message: "", isPhoto: false, isAudio: true, audioData: audioData, key: key)
                        MessageManager.shared.updateChat(chatId: validChatId, isLastMessageRead: false, receiverUid: receiver ?? "", isPhoto: true, isAudio: false)
                       message = ""
                        DispatchQueue.main.async {
                            self.scrollToBottom += 1
                        }
                    }
                }
            }
        }
    }
       
       func prepareAudio(message: MessageModel) async {
           guard let audioUrl = URL(string: message.message) else {
               print("Invalid audio URL")
               return
           }
           let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           let localUrl = documentUrl.appendingPathComponent(audioUrl.lastPathComponent)
           if FileManager.default.fileExists(atPath: localUrl.path) {
               prepareAudioForUrl(audioUrl: localUrl.path)
           } else {
               let downloadUrl = URLSession.shared.downloadTask(with: audioUrl) { (tempUrl, _, error) in
                   guard let tempUrl = tempUrl, error == nil else { return }
                   do {
                       try FileManager.default.moveItem(at: tempUrl, to: localUrl)
                       DispatchQueue.main.async {
                           self.prepareAudioForUrl(audioUrl: localUrl.path)
                       }
                   } catch {
                       print("Error downloading audio file: \(error.localizedDescription)")
                   }
               }
               downloadUrl.resume()
           }
       }
       
       func prepareAudioForUrl(audioUrl: String) {
           let url = URL(fileURLWithPath: audioUrl)
           do {
               let audioData = try Data(contentsOf: url)
               audioPlayer = try AVAudioPlayer(data: audioData)
           } catch {
               print("Error preparing audio: \(error.localizedDescription)")
           }
       }
       
       func playAudio(message: MessageModel) async throws {
           if audioPlayer == nil {
               await prepareAudio(message: message)
           }
           audioPlayer?.play()
       }

       
    func formatTimestamp(timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let currentDate = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: currentDate) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            return timeFormatter.string(from: date)
        } else {
            let components = calendar.dateComponents([.hour], from: date, to: currentDate)
            if let hours = components.hour, hours < 24 {
                let timeFormatter = DateFormatter()
                timeFormatter.timeStyle = .short
                return timeFormatter.string(from: date)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .short
                dateFormatter.dateStyle = .medium
                return dateFormatter.string(from: date)
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
                return document.documentID
            } else {
                return nil
            }
        } catch {
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
}

