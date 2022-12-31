//
//  Attachment.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A class representation of a post attachment.
public class Attachment: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID associated with this attachment registered with the server.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// The type of attachment.
    public let type: AttachmentType

    /// The attachment's website URL.
    public let url: String

    /// The attachment's website URL to remote content.
    public let remoteURL: String?

    /// The attachment's website URL to the remote content's preview.
    public let previewURL: String?

    /// The attachment's website URL to text.
    public let textURL: String?

    /// The attachment's description.
    public let description: String?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        // swiftlint:disable:next identifier_name
        case id
        case type
        case url
        case remoteURL = "remote_url"
        case previewURL = "preview_url"
        case textURL = "text_url"
        case description
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Attachment: Hashable {
    public static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
