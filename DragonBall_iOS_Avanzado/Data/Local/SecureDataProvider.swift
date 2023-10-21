//
//  SecureDataProvider.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 13/10/23.
//

import Foundation
import KeychainSwift

protocol SecureDataProviderProtocol {
    func save(token: String)
    func getToken() -> String?
    func deleteAllKeys()
}

final class SecureDataProvider: SecureDataProviderProtocol {
    let keychain = KeychainSwift()
    
    private enum Key {
        static let token = "KEY_KEYCHAIN_TOKEN"
    }
    
    func save(token: String) {
        keychain.set(token, forKey: Key.token)
    }
    
    func getToken() -> String? {
        keychain.get(Key.token)
    }
}
