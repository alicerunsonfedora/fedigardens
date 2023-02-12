//
//  Notification.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A notification the user has received.
public struct Notification: Codable, Identifiable {
    /// A representation of the different account notification types.
    public enum NotificationType: String, Codable {
        /// When an account follows the user
        case follow

        /// When an account mentions the user in a post
        case mention

        /// When an account reblogs the user's post
        case reblog

        /// When an account favorites the user's post
        case favourite

        /// When an account is requesting to follow the user
        case followRequest = "follow_request"

        /// Someone you enabled notifications for has posted a status
        case status

        /// A poll you have voted in or created has ended
        case poll

        /// A status you interacted with has ended
        case update
    }

    /// A unique identifier generated for this notification.
    public let uuid = UUID()

    /// The ID of the notification from the server.
    public let id: String

    /// The type of notification being delivered.
    public let type: NotificationType

    /// The ISO date of when this notification was created.
    public let createdAt: String

    /// The account that the notification was triggered from.
    public let account: Account

    /// The post associated with this notification.
    public let status: Status?

    // MARK: COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case account
        case status
        case createdAt = "created_at"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Notification: Hashable {
    public static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
