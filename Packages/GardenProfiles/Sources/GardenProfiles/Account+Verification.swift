//
//  Account+Verification.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/8/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import Foundation

/// An enumeration that represents an account's verified status.
public enum Verification {
    /// The account is not verified.
    case unverified

    /// The account has verification to a specified domain.
    case verified(String)
}

public extension Account {
    /// The account's preferred name.
    ///
    /// This value will return the first available value it finds in the display name, username, or account.
    var accountName: String {
        if !displayName.isEmpty { return displayName }
        if !username.isEmpty { return "@\(username)" }
        return "@\(acct)"
    }

    /// The account's verification status.
    var verification: Verification {
        if let verifiedAtField = fields.first(where: { field in field.verifiedAt != nil }) {
            return .verified(verifiedAtField.value)
        }
        return .unverified
    }
}
