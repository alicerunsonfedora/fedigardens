//
//  Notification.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/**
 A class representation of a notification.
 */
public class Notification: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID of the notification from the server.
    // swiftlint:disable:next identifier_name
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
        // swiftlint:disable:next identifier_name
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
