//
//  ExtendedDescription.swift
//
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// An extended description of an instance that is shown on the about page.
public struct ExtendedDescription: Codable, Identifiable {
    /// A unique identifier generated for this description.
    public let id = UUID()

    /// The ISO-8601 date string for when the description was last updated.
    public let updatedAt: String

    /// The HTML content of the description.
    public let content: String

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case content
        case updatedAt = "updated_at"
    }
}

extension ExtendedDescription: Hashable {}
