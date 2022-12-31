//
//  Card.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A class representation of a content card.
public class Card: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID for this card.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The title for this card.
    public let title: String

    /// The description for this card.
    public let description: String

    /// The URL to this card, if applicable.
    public let image: String?

    /// The type of content for this card.
    public let type: CardType

    /// The content author's name.
    public let authorName: String?

    /// The content author's website URL.
    public let authorURL: String?

    /// The content provider's name.
    public let providerName: String?

    /// The content provider's website URL.
    public let providerURL: String?

    /// The content's HTML code.
    public let html: String?

    /// The suggested width for this card.
    public let width: Int?

    /// The suggested height for this card.
    public let height: Int?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case image
        case type
        case authorName = "author_name"
        case authorURL = "author_url"
        case providerName = "provider_name"
        case providerURL = "provider_url"
        case html
        case width
        case height
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Card: Hashable {
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
