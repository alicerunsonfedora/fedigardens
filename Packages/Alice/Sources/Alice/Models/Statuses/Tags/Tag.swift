//
//  Tag.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A representation of a hashtag.
public struct Tag: Codable, Identifiable {
    /// A unique identifier generated for this tag.
    public let id = UUID()

    /// The name of the tag.
    public let name: String

    /// The URL to access posts with this tag.
    public let url: String

    /// The weekly history of this tag.
    public let history: [History]?

    /// Whether the user is currently following this tag.
    public let following: Bool?

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case name
        case url
        case history
        case following
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Tag: Hashable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
