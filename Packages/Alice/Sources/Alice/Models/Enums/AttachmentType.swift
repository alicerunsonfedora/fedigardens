//
//  AttachmentType.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// An enumerated representation of an attachment's type.
public enum AttachmentType: String, Codable {
    /// When the attachment's type is unknown to the server.
    case unknown

    /// When the attachment is an image or image-like object.
    case image

    /// When the attachment is a GIF or GIF video.
    case gifv

    /// When the attachment is an audio file.
    case audio

    /// When the attachment is a video.
    case video
}
