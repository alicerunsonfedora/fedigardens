//
//  MockKeychain.swift
//  
//
//  Created by Marquis Kurt on 5/6/23.
//

import Foundation
import Alice

class AliceMockKeychain: AliceSecurityModule {
    private var keychain = [String: String]()

    func setSecureStore(_ value: String?, forKey key: String) {
        keychain[key] = value
    }

    func getSecureStore(_ key: String) -> String? {
        return keychain[key]
    }

    func flush() {
        keychain.removeAll()
    }
}
