//
//  Announcement.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents an announcement set by an administrator.
public class Announcement: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The announcement id.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// The content of the announcement.
    public let text: String

    /// Whether the announcement is currently active.
    public let published: Bool

    /// Whether the announcement has a start/end time.
    public let allDay: Bool

    /// When the announcement was created.
    public let createdAt: String

    /// When the announcement was last updated.
    public let updatedAt: String

    /// Whether the announcement has been read by the user.
    public let read: Bool

    /// Emoji reactions attached to the announcement.
    public let reactions: [AnnouncementReaction]

    /// When the future announcement was scheduled.
    public let scheduledAt: String?

    /// When the future announcement will start.
    public let startsAt: String?

    /// When the future announcement will end.
    public let endsAt: String?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {

        // swiftlint:disable:next identifier_name
        case id

        case text
        case published
        case allDay
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case read
        case reactions
        case scheduledAt = "scheduled_at"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Announcement: Hashable {
    public static func == (lhs: Announcement, rhs: Announcement) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
