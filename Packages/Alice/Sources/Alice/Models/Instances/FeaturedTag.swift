//
//  FeaturedTag.swift
//
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// A tag that an account is currently featuring.
public struct FeaturedTag: Codable, Identifiable {
    /// The tag's unique identifier.
    public let id: String

    /// The name of the tag.
    public let name: String

    /// A URL pointing to the tag's page on that instance.
    public let url: String

    /// The number of statuses that contain this tag.
    public let numberOfStatuses: String

    /// An ISO-8601 date string of when the last status containing this tag was created.
    public let lastStatusAt: String

    private enum CodingKeys: String, CodingKey {
        case id, name, url
        case numberOfStatuses = "statuses_count"
        case lastStatusAt = "last_status_at"
    }
}

extension FeaturedTag: Hashable {}
