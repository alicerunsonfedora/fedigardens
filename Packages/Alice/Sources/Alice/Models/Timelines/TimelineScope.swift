//
//  TimelineScope.swift
//  Chica
//
//  Created by Marquis Kurt on 5/8/21.
//

import Foundation

/// An enumeration that represents the different types of timelines.
public enum TimelineScope {
    /// The local or public timeline.
    ///
    /// This uses the same endpoint to fetch timeline data. To specify local data, include the `local` parameter in
    /// your request.
    /// - Example:
    ///     `try await Alice.shared.get(.network, params: ["local": "true"])`
    case network

    /// The user's timeline.
    case home

    /// The user's direct messages.
    case messages

    /// A timeline from a given list.
    case list(id: String)

    /// A timeline of posts that correspond to a hashtag.
    case tag(tag: String)

    /// The full path to a timeline endpoint
    var path: String {
        switch self {
        case .home:
            return "/api/v1/timelines/home"
        case .network:
            return "/api/v1/timelines/public"
        case .messages:
            return "/api/v1/conversations"
        case .list(let id):
            return "/api/v1/timelines/list/\(id)"
        case .tag(let tag):
            return "/api/v1/timelines/tag/\(tag)"
        }
    }
}
