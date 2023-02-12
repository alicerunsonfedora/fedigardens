//
//  UserFilter.swift
//  
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// A filter the user has generated to filter out content.
public struct UserFilter: Codable, Identifiable {
    /// A typealias referring to the filter's keyword.
    public typealias Keyword = UserFilterKeyword

    /// An enumeration representing the context in which a filter applies.
    public enum Context: String, Codable {
        case home, notifications, `public`, thread, account
    }

    /// An enumeration representing an action that can be taken if content matches the filter.
    public enum Action: String, Codable {
        case warn, hide
    }

    /// The filter's identifier.
    public let id: String // swiftlint:disable:this identifier_name

    /// The filter's title.
    public let title: String

    /// The context in which the filter applies.
    public let context: [Context]

    /// The ISO-8601 date string at which the filter expires.
    public let expiresAt: String?

    /// The action to take when specified content matches the filter's requirements.
    public let filterAction: Action

    /// The keywords that trigger this filter.
    public let keywords: [Keyword]

    /// The statuses affected by this filter.
    public let statuses: [UserFilterStatus]

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, title, context, keywords, statuses // swiftlint:disable:this identifier_name
        case filterAction = "filter_action"
        case expiresAt = "expires_at"
    }
}

extension UserFilter: Hashable {}
