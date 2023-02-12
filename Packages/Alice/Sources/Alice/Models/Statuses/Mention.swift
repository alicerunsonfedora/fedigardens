//
//  Mention.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A mention model that contains the data for an account that is mentioned in a given post.
public struct Mention: Codable, Identifiable {
    /// The ID associated with this mention from the server.
    public let id: String

    /// The mentioned account's username.
    public let username: String

    /// The mentioned account's given username and domain, if applicable.
    public let acct: String

    /// The website URL to the mentioned account's profile.
    public let url: String
}

/// Grants us conformance to `Hashable` for _free_
extension Mention: Hashable {
    public static func == (lhs: Mention, rhs: Mention) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
