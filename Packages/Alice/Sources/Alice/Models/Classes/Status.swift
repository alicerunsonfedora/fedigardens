//
//  Status.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents a status posted by an account.
public class Status: Codable {

    // MARK: - STORED PROPERTIES
    /// A universally unique identifier for use in views that require fully stable IDs.
    public let uuid = UUID()

    /// The status' unique identifier.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// URI of the status used for federation.
    public let uri: String

    /// The time when the status was created
    public let createdAt: String

    /// The user account that authored this status
    public let account: Account

    /// HTML-encoded status body content.
    public let content: String

    /// The visibility of the status,
    /// because posts can be restricted to a certain selection of people, or even be used as a direct message.
    public let visibility: Visibility

    /// Whether media attachments should be hidden by default by the client.
    public let sensitive: Bool?

    /**
    *   Subject or summary line, below which status content is collapsed until expanded.
    *   If not empty, this value serves as a warning text that will be displayed before rendering the actual content.
    */
    public let spoilerText: String

    /// An array of the media that is attached to this status.
    public let mediaAttachments: [Attachment]

    /// The application used to post this status.
    public let application: Application?

    /// An array of the mentions of users within the status content.
    public let mentions: [Mention]

    /// An array of all the hashtags used within the status content.
    public let tags: [Tag]

    /// An array of all the custom emoji to be used when rendering status content.
    public let emojis: [Emoji]

    /// How many boosts this status has received.
    public let reblogsCount: Int

    /// How many favourites this status has received.
    public let favouritesCount: Int

    /// How many replies this status has received.
    public let repliesCount: Int

    /// A link to the status's HTML representation.
    public let url: URL?

    /// ID of the status being replied, if the status is not a reply it will be nil.
    public let inReplyToID: String?

    /// If `inReplyToID` is not nil, this would equal to the ID of the account being replied to, else nil.
    public let inReplyToAccountID: String?

    /// The status being reblogged.
    public let reblog: Status?

    /// The poll attached to the status.
    public let poll: Poll?

    /// Preview card for links included within status content.
    public let card: Card?

    /// Primary language of this status.
    public let language: String?

    /**
     Plain-text source of a status.
     
     Returned instead of content when status is deleted,
     so the user may redraft from the source text without the client having to reverse-engineer
     the original text from the HTML content.
    */
    public let text: String?

    /// Whether the user has reblogged the status.
    public let reblogged: Bool?

    /// Whether the user has favourited the status.
    public let favourited: Bool?

    /// Have you pinned this status? Only appears if the status is pinnable.
    public let pinned: Bool?

    /// Have you bookmarked this status?
    public let bookmarked: Bool?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        // swiftlint:disable:next identifier_name
        case id
        case uri
        case createdAt = "created_at"
        case account
        case content
        case visibility
        case sensitive
        case spoilerText = "spoiler_text"
        case mediaAttachments = "media_attachments"
        case application
        case mentions
        case tags
        case emojis
        case reblogsCount = "reblogs_count"
        case favouritesCount = "favourites_count"
        case repliesCount = "replies_count"
        case url
        case inReplyToID = "in_reply_to_id"
        case inReplyToAccountID = "in_reply_to_account_id"
        case reblog
        case poll
        case card
        case language
        case text
        case reblogged
        case favourited
        case pinned
        case bookmarked
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Status: Hashable {
    public static func == (lhs: Status, rhs: Status) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
