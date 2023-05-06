//
//  File.swift
//  
//
//  Created by Marquis Kurt on 5/6/23.
//

import Foundation
import KeychainAccess

public protocol AliceSecurityModule {
    func setSecureStore(_ value: String?, forKey key: String)
    func getSecureStore(_ key: String) -> String?
    func flush()
}

extension Keychain: AliceSecurityModule {
    public func setSecureStore(_ value: String?, forKey key: String) {
        self[key] = value
    }

    public func getSecureStore(_ key: String) -> String? {
        return self[key]
    }

    public func flush() {
        try? self.removeAll()
    }
}
