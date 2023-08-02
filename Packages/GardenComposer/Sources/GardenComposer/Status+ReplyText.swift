//
//  Status+ReplyText.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/8/23.
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

extension Status {
    static let mentionRegex = #/\@([a-zA-Z0-9\_]+)\@([a-zA-Z0-9\_\-.]+)/#

    func replyMentions(including existingParticipants: String = "", excluding currentUser: Account) -> String {
        var allMentions = mentions
        if let reblog {
            allMentions.append(contentsOf: reblog.mentions)
        }

        let otherMembers = Mention.members(of: allMentions, excluding: [account.acct, currentUser.acct])
        var allParticipants = [existingParticipants, otherMembers]

        if account != currentUser {
            allParticipants.append("@\(account.acct)")
        }

        // Perform a second padd to add the reblogged author if they weren't already included.
        if let reblog, !allMentions.map(\.acct).contains(reblog.account.acct), reblog.account != currentUser {
            allParticipants.append("@\(reblog.account.acct)")
        }

        return allParticipants.filter(\.isNotPureWhitespace).joined(separator: " ")
    }
}

extension Mention {
    static func members(of party: [Mention], excluding respondents: [String]) -> String {
        party.filter { member in !respondents.contains(member.acct) }
            .map { member in "@\(member.acct)" }
            .joined(separator: " ")
    }
}

extension String {
    var isPureWhitespace: Bool {
        allSatisfy(\.isWhitespace)
    }

    var isNotPureWhitespace: Bool {
        !isPureWhitespace
    }
}
