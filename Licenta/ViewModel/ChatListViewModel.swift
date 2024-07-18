//
//  ChatListViewModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 10.04.2024.
//

import SwiftUI
import Firebase

@MainActor
final class ChatListViewModel: ObservableObject {
    @Published var currentTab: Tab = .home
    @Published var showSheet: Bool = false
    @Published var chat: ChatModel?
    @Published var chatIdToDelete: String?
    @Published var chatIdToHide: String?
    @Published var showDeleteChatDialog: Bool = false
    @Published var showHideChatDialog: Bool = false

    
//    func chatRowSecond(for chat: ChatModel, status: String, currentUid: String) -> some View {
//        HStack(spacing: 0.0){
//            ZStack{
//                if let profilePhotoURL = chat.secondProfilePicture {
//                    AsyncImage(url: URL(string: profilePhotoURL)) { phase in
//                        switch phase {
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .clipShape(Circle())
//                                .frame(width: 80, height: 80)
//                        case .empty:
//                            ProgressView()
//                                .frame(width: 80, height: 80)
//                        default:
//                            Image(systemName: "person.circle")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 60, height: 60)
//                                .padding()
//                        }
//                    }
//                }
//                if status == "online" {
//                    Image(systemName: "circle.fill")
//                        .frame(width: 15)
//                        .foregroundStyle(.green)
//                        .offset(x: 18, y: 18)
//                        .overlay {
//                            Circle()
//                                .stroke(.thinMaterial, lineWidth: 2)
//                                .offset(x: 18, y: 18)
//                        }
//                } else {
//                    Image(systemName: "circle.fill")
//                        .frame(width: 15)
//                        .foregroundStyle(.gray)
//                        .offset(x: 18, y: 18)
//                        .overlay {
//                            Circle()
//                                .stroke(.thinMaterial, lineWidth: 2)
//                                .offset(x: 18, y: 18)
//                        }
//                }
//            }
//            VStack(alignment: .leading, spacing: 0.0){
//                Text(chat.secondName)
//                    .font(.title3.bold())
//                
//                if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
//                    if chat.isPhoto {
//                        Text("Photo.")
//                            .font(.subheadline.bold())
//                            .foregroundStyle(.primary)
//                            .lineLimit(1)
//                    } else if chat.isAudio {
//                        Text("Audio Message.")
//                            .font(.subheadline.bold())
//                            .foregroundStyle(.primary)
//                            .lineLimit(1)
//                    } else {
//                        Text(chat.lastMessage ?? "")
//                            .font(.subheadline.bold())
//                            .foregroundStyle(.primary)
//                            .lineLimit(1)
//                    }
//                } else {
//                    if chat.isPhoto {
//                        Text("Photo.")
//                            .font(.subheadline)
//                            .foregroundStyle(Color(.gray))
//                            .lineLimit(1)
//                    } else if chat.isAudio {
//                        Text("Audio Message.")
//                            .font(.subheadline)
//                            .foregroundStyle(Color(.gray))
//                            .lineLimit(1)
//                    } else {
//                        Text(chat.lastMessage ?? "")
//                            .font(.subheadline)
//                            .foregroundStyle(Color(.gray))
//                            .lineLimit(1)
//                    }
//                }
//            }
//            Spacer()
//            VStack(alignment: .trailing, spacing: 20) {
//                if let lastMessageTime = chat.lastMessageTime {
//                    if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
//                        Text(formatTimestamp(timestamp: lastMessageTime))
//                            .font(.caption.bold())
//                            .foregroundStyle(.primary)
//                    } else {
//                        Text(formatTimestamp(timestamp: lastMessageTime))
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//            }
//            .font(.system(size: 14, weight: .semibold))
//        }
//        .padding()
//        .frame(maxWidth: .infinity ,maxHeight: 90)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
//        .overlay() {
//            RoundedRectangle(cornerRadius: 16)
//                .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
//        }
//      //  .padding(.horizontal)
//    }
//    
//    func chatRowFirst(for chat: ChatModel, status: String, currentUid: String) -> some View {
//        HStack(spacing: 0.0){
//            
//            ZStack{
//                if let profilePhotoURL = chat.firstProfilePicture {
//                    AsyncImage(url: URL(string: profilePhotoURL)) { phase in
//                        switch phase {
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .clipShape(Circle())
//                                .frame(width: 80, height: 80)
//                        case .empty:
//                            ProgressView()
//                                .frame(width: 80, height: 80)
//                        default:
//                            Image(systemName: "person.circle")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 60, height: 60)
//                                .padding()
//                        }
//                    }
//                }
//                if status == "online" {
//                                    Image(systemName: "circle.fill")
//                                        .frame(width: 15)
//                                        .foregroundStyle(.green)
//                                        .offset(x: 18, y: 18)
//                                        .overlay {
//                                            Circle()
//                                                .stroke(.thinMaterial, lineWidth: 2)
//                                                .offset(x: 18, y: 18)
//                                        }
//                                } else {
//                                    Image(systemName: "circle.fill")
//                                        .frame(width: 15)
//                                        .foregroundStyle(.gray)
//                                        .offset(x: 18, y: 18)
//                                        .overlay {
//                                            Circle()
//                                                .stroke(.thinMaterial, lineWidth: 2)
//                                                .offset(x: 18, y: 18)
//                                        }
//                                }
//            }
//            VStack(alignment: .leading, spacing: 0.0){
//                Text(chat.firstName)
//                    .font(.title3.bold())
//                if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
//                    if chat.isPhoto {
//                        Text("Photo")
//                            .font(.subheadline.bold())
//                            .foregroundStyle(.primary)
//                            .lineLimit(1)
//                    }  else if chat.isAudio {
//                        Text("Audio Message.")
//                            .font(.subheadline.bold())
//                            .foregroundStyle(.primary)
//                            .lineLimit(1)
//                    } else {
//                        Text(chat.lastMessage ?? "")
//                            .font(.subheadline.bold())
//                            .foregroundStyle(.primary)
//                            .lineLimit(1)
//                    }
//                } else {
//                    if chat.isPhoto {
//                        Text("Photo")
//                            .font(.subheadline)
//                            .foregroundStyle(Color(.gray))
//                            .lineLimit(1)
//                    } else if chat.isAudio {
//                        Text("Audio Message.")
//                            .font(.subheadline)
//                            .foregroundStyle(Color(.gray))
//                            .lineLimit(1)
//                    } else {
//                        Text(chat.lastMessage ?? "")
//                            .font(.subheadline)
//                            .foregroundStyle(Color(.gray))
//                            .lineLimit(1)
//                    }
//                }
//            }
//            Spacer()
//            VStack(alignment: .trailing, spacing: 20) {
//                if let lastMessageTime = chat.lastMessageTime {
//                    if !chat.isLastMessageRead && chat.lastMessageReceiverUid == currentUid {
//                        Text(formatTimestamp(timestamp: lastMessageTime))
//                            .font(.caption.bold())
//                            .foregroundStyle(.primary)
//                    } else {
//                        Text(formatTimestamp(timestamp: lastMessageTime))
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    }
//                }
////                Image(systemName: "checkmark")
////                    .foregroundStyle(.secondary)
//            }
//            .font(.system(size: 14, weight: .semibold))
//        }
//        .padding()
//        .frame(maxWidth: .infinity ,maxHeight: 90)
//        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
//        .overlay() {
//            RoundedRectangle(cornerRadius: 16)
//                .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
//        }
//       // .padding(.horizontal)
//    }
    
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
                dateFormatter.dateStyle = .medium
                return dateFormatter.string(from: date)
            }
        }
    }
}


