//
//  ContactsModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 24.04.2024.
//

import Foundation
import Firebase

struct ContactsModel: Codable, Equatable, Hashable {
    let userId: String
    let profileImage: String?
    let user_name: String
    let token: String
    
    func hash(into hasher: inout Hasher) {
          hasher.combine(userId)
      }

      static func ==(lhs: ContactsModel, rhs: ContactsModel) -> Bool {
          return lhs.userId == rhs.userId
      }
}
