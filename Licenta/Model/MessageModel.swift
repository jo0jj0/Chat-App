
import Foundation
import Firebase

struct MessageModel: Codable, Hashable {
    let messageId: String
    let senderId: String
    let message: String
    let isPhoto: Bool
    let isAudio: Bool
    let sentAt: Timestamp
    let firstDeleteId: String
    let secondDeleteId: String
    let isDeletedForAll: Bool
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(messageId)
       }

       static func ==(lhs: MessageModel, rhs: MessageModel) -> Bool {
           return lhs.messageId == rhs.messageId
       }
}
