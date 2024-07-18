//
//  TokenGenerator.swift
//  Licenta
//
//  Created by Georgiana Costea on 18.06.2024.
//

import Foundation
import JWTKit

struct MyPayload: JWTPayload {
    var user_id: String

    func verify(using signer: JWTSigner) throws {}
}

class JWTManager {
    private let secretKey: String
    private let signer: JWTSigner
    private let user_id: String

    init(secretKey: String, user_id: String) {
        self.secretKey = secretKey
        self.signer = JWTSigner.hs256(key: Data(secretKey.utf8))
        self.user_id = user_id
    }

    func generateToken() -> String? {
        let payload = MyPayload(user_id: user_id)
        
        do {
            let jwt = try signer.sign(payload)
            return jwt
        } catch {
            print("Failed to sign JWT: \(error)")
            return nil
        }
    }
}

