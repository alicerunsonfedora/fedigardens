//
//  PostVisibility.swift
//  Chica
//
//  Created by Marquis Kurt on 7/6/20.
//

import Foundation

@available(*, deprecated, renamed: "PostVisibility")
public typealias Visibility = PostVisibility

/**
 An enumerated representation of a post's visibility.
 
 Posts can be restricted to a certain selection of people or used as a direct message.
 */
public enum PostVisibility: String, Codable, CaseIterable {
    /// When a post is meant for everyone to see.
    case `public`

    /// When a post is meant to be followers-only.
    case `private`

    /// When a post is meant to be visible to everyone, but only via link.
    case unlisted

    /// When a post is meant to be a direct message, only intended for its recipients.
    case direct
}
