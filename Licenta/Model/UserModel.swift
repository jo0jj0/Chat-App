//
//  UserModel.swift
//  Licenta
//
//  Created by Georgiana Costea on 03.04.2024.
//

import Foundation
import Firebase

public struct UserModel: Codable {
    let user_id: String
    let profile_image: String?
    let email: String
    var user_name: String    
    let createdAt: Timestamp
    let token: String

}
