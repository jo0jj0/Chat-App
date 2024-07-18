//
//  CallModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 22.06.2024.
//

import Foundation
import Firebase

struct CallModel: Codable, Equatable, Hashable {
    
    let id: String
    let profilePicture: String
    let userName: String
    let createdAt: Timestamp
    let duration: Int
    let callerId: String
    let receiverId: String
    var callStarted: Bool
//    var isVideo: Bool
    
    func hash(into hasher: inout Hasher) {
          hasher.combine(id)
      }

      static func ==(lhs: CallModel, rhs: CallModel) -> Bool {
          return lhs.id == rhs.id
      }
}
