//
//  UserFilterKeyword.swift
//
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// A keyword registered in a user filter.
public struct UserFilterKeyword: Codable, Identifiable {
    /// The idenfitier of the keyword.
    public let id: String

    /// The keyword phrase included in the filter.
    public let keyword: String

    /// Whether the keyword phrase respects word boundaries.
    public let useWordBoundaries: Bool

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case id, keyword
        case useWordBoundaries = "whole_word"
    }
}

extension UserFilterKeyword: Hashable {}
