//
//  Instance.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/**
 A class representation of a fediverse instance.
 
 A fediverse instance is the server that the user lives on. The following class gives information
 about the instance and who can be contacted.
 */
public struct Instance: Codable, Identifiable {
    /// A rule the server enforces.
    public struct Rule: Codable, Identifiable, Hashable {
        /// The identifier for the rule.
        public let id: String

        /// The rule's text contents.
        public let text: String
    }

    /// The ID for this server.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The website URI for this instance.
    public let domain: String

    /// The instance server's title or name.
    public let title: String

    /// The instance server's description.
    public let description: String

    /// The instance server's contact email address.
    public let email: String

    /// The instance server's software version.
    public let version: String

    /// The website URL to the instance server's thumbnail image.
    public let thumbnail: String?

    /// The instance server's supported languages.
    public let languages: [String]

    /// The instance server's contact account.
    public let contactAccount: Account

    /// The rules that the instance encforces.
    public let rules: [Rule]

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case domain
        case title
        case description
        case email = "contact[email]"
        case version
        case thumbnail
        case languages
        case contactAccount = "contact[account]"
        case rules
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Instance: Hashable {
    public static func == (lhs: Instance, rhs: Instance) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
