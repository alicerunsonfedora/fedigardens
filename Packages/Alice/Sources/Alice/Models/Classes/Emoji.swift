//
//  Emoji.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents a custom emoji.
public class Emoji: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// Required for being able to iterate through this data model using SwiftUI
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The shortcode of the emoji
    public let shortcode: String

    /// URL to the emoji static image
    public let staticURL: URL

    /// URL to the emoji image
    public let url: URL

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        case shortcode
        case staticURL = "static_url"
        case url
    }

}

/// Grants us conformance to `Hashable` for _free_
extension Emoji: Hashable {
    public static func == (lhs: Emoji, rhs: Emoji) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
