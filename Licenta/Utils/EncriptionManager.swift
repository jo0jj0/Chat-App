//
//  EncriptionManager.swift
//  Licenta
//
//  Created by Georgiana Costea on 23.06.2024.
//

import Foundation
import CryptoSwift

enum EncryptionError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidKeyLength
}


let encryptionKey: String = "LfNu8byvNk5XwTse7b1ed1Rw6arB67qe"

func aesEncrypt(message: String, key: String) throws -> String {
    guard let keyData = key.data(using: .utf8) else {
        throw EncryptionError.invalidKeyLength
    }
    let iv = generateRandomBytes(count: 16) // Generate a random IV for each encryption
    
    do {
        let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7)
        let encryptedBytes = try aes.encrypt(Array(message.utf8))
        let encryptedData = Data(encryptedBytes)
        let encryptedBase64 = encryptedData.base64EncodedString()
        return iv.base64EncodedString() + ":" + encryptedBase64
    } catch {
        throw EncryptionError.encryptionFailed
    }
}

func aesDecrypt(encryptedMessage: String, key: String) throws -> String {
    if encryptedMessage.hasPrefix("https://firebasestorage") {
        return encryptedMessage
    }
    
    guard let keyData = key.data(using: .utf8) else {
        throw EncryptionError.invalidKeyLength
    }
    
    let components = encryptedMessage.split(separator: ":")
    guard components.count == 2,
          let ivData = Data(base64Encoded: String(components[0])),
          let encryptedData = Data(base64Encoded: String(components[1])) else {
        throw EncryptionError.decryptionFailed
    }
    
    do {
        let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: ivData.bytes), padding: .pkcs7)
        let decryptedBytes = try aes.decrypt(Array(encryptedData))
        guard let decryptedMessage = String(bytes: decryptedBytes, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }
        return decryptedMessage
    } catch {
        throw EncryptionError.decryptionFailed
    }
}

func generateRandomBytes(count: Int) -> Data {
    var bytes = [UInt8](repeating: 0, count: count)
    let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
    assert(status == errSecSuccess)
    return Data(bytes)
}

func generateEncryptionKey() -> String? {
    var keyData = Data(count: 32)
    let result = keyData.withUnsafeMutableBytes { (rawBufferPointer: UnsafeMutableRawBufferPointer) -> Int32 in
        guard let baseAddress = rawBufferPointer.baseAddress else {
            return errSecAllocate
        }
        return SecRandomCopyBytes(kSecRandomDefault, 32, baseAddress)
    }
    
    if result == errSecSuccess {
        let base64Key = keyData.base64EncodedString()
        return String(base64Key.prefix(32)) 
    } else {
        print("Error generating key: \(result)")
        return nil
    }
}
