//
//  Context.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A class that contains the replies to a post as a descendant, or prior statuses leading up to the current post.
public struct Context: Codable, Identifiable {
    /// A unique identifier generated for this context.
    public let id = UUID()

    /// The posts that precede the given post.
    public let ancestors: [Status]

    /// The posts that follow the given post.
    public let descendants: [Status]

    // MARK: - Coding Keys
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
