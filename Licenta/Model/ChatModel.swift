//
//  ChatModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 02.05.2024.
//

import Foundation
import Firebase

struct ChatModel: Codable, Equatable, Hashable {
    var id: String
    let firstUid: String
    var secondUid: String
    let firstName: String
    let secondName: String
    let firstProfilePicture: String?
    let secondProfilePicture: String?
    let lastMessage: String?
    let lastMessageTime: Timestamp?
    let isLastMessageRead: Bool
    let lastMessageReceiverUid: String
    let isPhoto: Bool
    let isAudio: Bool
    let callId: String
    let firstToken: String
    let secondToken: String
    let firstDeleteId: String
    let secondDeleteId: String
    let firstHiddenId: String
    let secondHiddenId: String
    let key: String
    
    func hash(into hasher: inout Hasher) {
          hasher.combine(id)
      }

      static func ==(lhs: ChatModel, rhs: ChatModel) -> Bool {
          return lhs.id == rhs.id
      }
}
