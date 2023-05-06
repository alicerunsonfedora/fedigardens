//
//  AnnouncementReaction.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents a reaction to an Announcement.
public struct AnnouncementReaction: Codable, Identifiable {
    /// The reaction id, needed for iterating through the reactions.
    public let id = UUID()

    /// The emoji used for the reaction. Either a unicode emoji, or a custom emoji's shortcode.
    public let name: String

    /// The total number of users who have added this reaction.
    public let count: Int

    /// Whether the authorized user has added this reaction to the announcement.
    public let reacted: Bool

    /// A link to the custom emoji.
    public let url: String

    /// A link to a non-animated version of the custom emoji.
    public let staticUrl: String

    // MARK: - CodingKeys

    private enum CodingKeys: String, CodingKey {
        case name
        case count
        case reacted = "me"
        case url
        case staticUrl = "static_url"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension AnnouncementReaction: Hashable {
    public static func == (lhs: AnnouncementReaction, rhs: AnnouncementReaction) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
