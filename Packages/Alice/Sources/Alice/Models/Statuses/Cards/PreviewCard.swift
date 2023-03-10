//
//  Card.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A preview card generated from the OpenGraph attributes of a URL embedded in a post.
public struct PreviewCard: Codable, Identifiable {
    /// A unique identifier generated for this card.
    public let id = UUID()

    /// The title for this card.
    public let title: String

    /// The description for this card.
    public let description: String

    /// The URL to this card, if applicable.
    public let image: String?

    /// The type of content for this card.
    public let type: PreviewCardType

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

    /// A hash generated by the BlurHash algorithm used for creating thumbnails.
    public let blurhash: String?

    // MARK: - Coding Keys

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
        case blurhash
    }
}

/// Grants us conformance to `Hashable` for _free_
extension PreviewCard: Hashable {
    public static func == (lhs: PreviewCard, rhs: PreviewCard) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
