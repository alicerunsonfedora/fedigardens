//
//  Tag.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A class representation of a hashtag.
public class Tag: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID associated with this tag.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The name of the tag.
    public let name: String

    /// The URL to access posts with this tag.
    public let url: String

    /// The weekly history of this tag.
    public let history: [History]?

    // MARK: - COMPUTED PROPERTIES

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case history
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
