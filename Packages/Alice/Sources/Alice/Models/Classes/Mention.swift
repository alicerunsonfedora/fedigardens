//
//  Mention.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/**
 A class representation of a mention.
 
 A mention model contains the data for an account that is mentioned in a given post.
 */
public class Mention: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID associated with this mention from the server.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// The mentioned account's username.
    public let username: String

    /**
    The mentioned account's given username and domain, if applicable.
     
    This will otherwise be equivalent to the `username` value for this account.
    */
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
