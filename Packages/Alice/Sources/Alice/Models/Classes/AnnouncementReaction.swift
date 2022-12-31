//
//  AnnouncementReaction.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents an emoji reaction to an Announcement.
public class AnnouncementReaction: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The reaction id, needed for iterating through the reactions.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The emoji used for the reaction. Either a unicode emoji, or a custom emoji's shortcode.
    public let name: String

    /// The total number of users who have added this reaction.
    public let count: Int

    /// Whether the authorized user has added this reaction to the announcement.
    // swiftlint:disable:next identifier_name
    public let me: Bool

    /// A link to the custom emoji.
    public let url: String

    /// A link to a non-animated version of the custom emoji.
    public let staticUrl: String

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {

        case name
        case count

        // swiftlint:disable:next identifier_name
        case me

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
