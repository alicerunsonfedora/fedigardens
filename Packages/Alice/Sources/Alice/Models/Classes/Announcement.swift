//
//  Announcement.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents an announcement set by an administrator.
public struct Announcement: Codable, Identifiable {
    /// A typealias that references an announcement's reaction.
    public typealias Reaction = AnnouncementReaction

    /// The announcement id.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// The content of the announcement.
    public let content: String

    /// Whether the announcement is currently active.
    public let published: Bool

    /// Whether the announcement has a start/end time.
    public let lastsAllDay: Bool

    /// When the announcement was created.
    public let publishedAt: String

    /// When the announcement was last updated.
    public let updatedAt: String

    /// Whether the announcement has been read by the user.
    public let read: Bool

    /// Emoji reactions attached to the announcement.
    public let reactions: [Reaction]

    /// When the future announcement was scheduled.
    public let scheduledAt: String?

    /// When the future announcement will start.
    public let startsAt: String?

    /// When the future announcement will end.
    public let endsAt: String?

    /// The tags that this announcement contains.
    public let tags: [Tag]

    /// The emojis that this announcement uses.
    public let emojis: [Emoji]

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id // swiftlint:disable:this identifier_name
        case content
        case published
        case lastsAllDay = "all_day"
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
        case read
        case reactions
        case scheduledAt = "scheduled_at"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case tags
        case emojis
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
