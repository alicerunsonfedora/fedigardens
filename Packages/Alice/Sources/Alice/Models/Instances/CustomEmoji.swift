//
//  Emoji.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents a custom emoji.
public struct CustomEmoji: Codable, Identifiable {
    /// A unique identifier generated for this emoji.
    public let id = UUID()

    /// The shortcode of the emoji
    public let shortcode: String

    /// URL to the emoji static image
    public let staticURL: URL

    /// URL to the emoji image
    public let url: URL

    // Whether the emoji is visible in the custom emoji picker.
    public let visibleInPicker: Bool

    /// The category this emoji belogs to.
    public let category: String?

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case shortcode
        case category
        case visibleInPicker = "visible_in_picker"
        case staticURL = "static_url"
        case url
    }
}

/// Grants us conformance to `Hashable` for _free_
extension CustomEmoji: Hashable {
    public static func == (lhs: CustomEmoji, rhs: CustomEmoji) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
