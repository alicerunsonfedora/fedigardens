//
//  Context.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/**
 A class representation of a post context.
 
 A context for a post contains all of the preceding posts that led to the post, as well as any posts that respond
 to a given post.
 */
public class Context: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID associated with this context.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The posts that precede the given post.
    public let ancestors: [Status]

    /// The posts that follow the given post.
    public let descendants: [Status]

    // MARK: - COMPUTED PROPERTIES

    enum CodingKeys: String, CodingKey {
        case ancestors
        case descendants
    }

}

/// Grants us conformance to `Hashable` for _free_
extension Context: Hashable {
    public static func == (lhs: Context, rhs: Context) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
