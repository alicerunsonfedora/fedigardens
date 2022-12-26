//
//  Chica+SignOut.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/25/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Chica
import KeychainAccess

extension Chica.OAuth {
    func signOut() {
        let keychain = Keychain(service: Chica.OAuth.keychainService)
        do {
            try keychain.removeAll()
            Chica.OAuth.shared.authState = .signedOut
        } catch {
            print("SIGN OUT ERR: \(error)")
        }
    }

}
