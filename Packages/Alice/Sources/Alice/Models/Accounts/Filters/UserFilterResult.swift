//
//  UserFilterResult.swift
//  
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// A filter that matches a given keyword or status.
public struct UserFilterResult: Codable, Identifiable {
    /// A unique identifer generated for this result.
    public let id = UUID()

    /// The filter that the result matches.
    public let filter: UserFilter

    /// The keywords that matched to this filter.
    public let keywordMatches: [String]?

    /// The status IDs that matched to this filter.
    public let statusMatches: [String]?

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case filter
        case keywordMatches = "keyword_matches"
        case statusMatches = "status_matches"
    }
}

extension UserFilterResult: Hashable {}
