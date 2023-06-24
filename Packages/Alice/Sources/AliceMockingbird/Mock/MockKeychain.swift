//
//  MockKeychain.swift
//  
//
//  Created by Marquis Kurt on 5/6/23.
//

import Foundation
import Alice

public class AliceMockKeychain: AliceSecurityModule {
    private var keychain = [String: String]()

    public init() {}

    public func setSecureStore(_ value: String?, forKey key: String) {
        keychain[key] = value
    }

    public func getSecureStore(_ key: String) -> String? {
        return keychain[key]
    }

    public func flush() {
        keychain.removeAll()
    }
}
