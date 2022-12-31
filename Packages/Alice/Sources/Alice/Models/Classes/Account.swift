//
//  Account.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/**
 A class representation of a fediverse account.
 
 An account is registered as a user on the fediverse. This class is used to identify a user in profile pages,
 searches, etc.
 */
public class Account: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The account's ID as registered by the server.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// The account's given username.
    public let username: String

    /**
     The account's given username and domain, if applicable.
     
     This will otherwise be equivalent to the `username` value for this account.
     */
    public let acct: String

    /**
     The account's display name.
     
     The display name may differ from what is provided in `username` and may contain emojis.
     */
    public let displayName: String

    /**
     Whether the account is locked or private.
     
     Locked accounts typically imply that a user needs the account's permission to follow that account.
     */
    public let locked: Bool

    /// The ISO date that the account was created.
    public let createdAt: String

    /// The number of accounts that this account follows.
    public let followersCount: Int

    /// The number of accounts that follow this account.
    public let followingCount: Int

    /// The number of posts or statuses that this account has created.
    public let statusesCount: Int

    /// The account's biography field or "note".
    public let note: String

    /// The account's URL on the server.
    public let url: String

    /// The URL associated with this account's avatar picture.
    public let avatar: String

    /**
     The URL associated with this account's avatar picture.
     
     If the `avatar` field points to an animated pictured, this property is used to target a static version.
     */
    public let avatarStatic: String

    /// The URL associated with this account's header picture.
    public let header: String

    /**
     The URL associated with this account's header picture.
     
     If the `header` field points to an animated pictured, this property is used to target a static version.
     */
    public let headerStatic: String

    /**
     The custom emojis associated with this account.
     
     Typically, this contains the emoji data for any emoji present in the display name of the account.
     */
    public let emojis: [Emoji]

    /// The account that the person has migrated to, if available.
    public let moved: Account?

    /// The table data associated with this account.
    public let fields: [Field]

    /// Whether or not the account is a bot.
    public let bot: Bool?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        // swiftlint:disable:next identifier_name
        case id
        case username
        case acct
        case displayName = "display_name"
        case locked
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case statusesCount = "statuses_count"
        case note
        case url
        case avatar
        case avatarStatic = "avatar_static"
        case header
        case headerStatic = "header_static"
        case emojis
        case moved
        case fields
        case bot
        case createdAt = "created_at"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Account: Hashable {
    public static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
