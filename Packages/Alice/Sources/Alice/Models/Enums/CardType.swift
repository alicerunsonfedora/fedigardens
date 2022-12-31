//
//  CardType.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// An enumerated representation of the card content type.
public enum CardType: String, Codable {

    /// When the content type is a link.
    case link

    /// When the content type includes a photo.
    case photo

    /// When the content type includes a video.
    case video

    /// When the content type contains rich content.
    case rich
}
