//
//  Relationship.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents the relationship between accounts, such as following / blocking / muting / etc.
public class Relationship: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The account id.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// Equals to `true` if the user is currently following the account.
    public let following: Bool

    /// Equals to `true` if the user has requested to follow the account.
    public let requested: Bool

    /// Equals to `true` if the user is featuring the account on its profile.
    public let endorsed: Bool

    /// Equals to `true` if the user is currently being followed by the account.
    public let followedBy: Bool

    /// Equals to `true` if the user is currently muting the account.
    public let muting: Bool

    /// Equals to `true` if the user is muting notifications from the account.
    public let mutingNotifications: Bool

    /// Equals to `true` if the user is receiving the account's boosts in its home timeline.
    public let showingReblogs: Bool

    /// Equals to `true` if the user is currently blocking the account.
    public let blocking: Bool

    /// Equals to `true` if the user is currently blocking the user's domain.
    public let domainBlocking: Bool

    /// Equals to `true` if the user was blocked by the account.
    public let blockedBy: Bool

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {

        // swiftlint:disable:next identifier_name
        case id

        case following
        case requested
        case endorsed
        case followedBy = "followed_by"
        case muting
        case mutingNotifications = "muting_notifications"
        case showingReblogs = "showing_reblogs"
        case blocking
        case domainBlocking = "domain_blocking"
        case blockedBy = "blocked_by"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Relationship: Hashable {
    public static func == (lhs: Relationship, rhs: Relationship) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
