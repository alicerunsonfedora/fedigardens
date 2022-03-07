//
//  AccountExtension.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 17/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import Foundation

extension Account {
    /// Returns the account name for this account.
    ///
    /// This will attempt to return the display name, username, or account name (in the order specified).
    func getAccountName() -> String {
        if !displayName.isEmpty { return displayName }
        if !username.isEmpty { return "@\(username)" }
        return "@\(acct)"
    }
}
