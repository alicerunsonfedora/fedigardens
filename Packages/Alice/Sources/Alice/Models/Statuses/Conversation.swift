//
//  Conversation.swift
//
//
//  Created by Marquis Kurt on 23/2/22.
//

import Foundation

/// A private conversation between a limited amount of users.
public struct Conversation: Codable {
    /// The ID of the conversation.
    public let id: String

    /// The list of accounts that are members of the conversation.
    public let accounts: [Account]

    /// Whether the user hasn't read the latest message.
    public let unread: Bool

    /// The last status in the conversation. This is typically used for display purposes.
    public let lastStatus: Status?

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case id
        case accounts
        case unread
        case lastStatus = "last_status"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Conversation: Hashable {
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
