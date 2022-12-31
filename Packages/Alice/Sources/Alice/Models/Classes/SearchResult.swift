//
//  SearchResult.swift
//  Chica
//
//  Created by Alex Modroño Vara on 19/7/21.
//

import Foundation

/// A class representation of a tag's history.
public class SearchResult: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID associated with this history event.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// Accounts that meet the specified query
    public let accounts: [Account]?

    /// Statuses that meet the specified query
    public let statuses: [Status]?

    /// Hashtags that meet the specified query
    public let hashtags: [Tag]?

    // MARK: - COMPUTED PROPERTIES
    enum CodingKeys: String, CodingKey {
        case accounts
        case statuses
        case hashtags
    }
}

/// Grants us conformance to `Hashable` for _free_
extension SearchResult: Hashable {
    public static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
