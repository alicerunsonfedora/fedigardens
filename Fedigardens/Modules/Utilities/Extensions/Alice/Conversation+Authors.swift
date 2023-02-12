//
//  Conversation+Authors.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 25/2/22.
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

extension Conversation {
    /// Returns a localized string containing the names of the participants, excluding the specified member ID.
    /// - Parameter currentUserID: The ID of the account to exclude in the localized string generation.
    func getAuthors(excluding currentUserID: String) -> String {
        if accounts.count <= 2 {
            return accounts.last { account in account.id != currentUserID }?.getAccountName() ?? "Person"
        }

        let firstTwoNames = Array(accounts.filter { account in account.id != currentUserID }[0 ..< 2])
        let firstAuthors = firstTwoNames.reduce("") { text, account in
            text + "\(account.getAccountName()), "
        }

        let remainingText = String(
            format: NSLocalizedString("direct.grouptitle", comment: "remains"),
            accounts.count - 2
        )

        return firstAuthors + remainingText
    }
}
