//
//  DomainBlock.swift
//  
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// A domain being blocked by an instance.
public struct DomainBlock: Codable, Identifiable {
    /// A representation of the different severity types a domain block can be registered as.
    public enum Severity: String, Codable {
        /// Users, notification, posts, etc. are silenced from timelines unless the current user follows anyone from this
        /// domain.
        case silence

        /// Incoming messages from this instance is dropped immediately, as if they never existed.
        case suspend
    }

    /// A unique identifier generated for this domain block.
    public let id = UUID() // swiftlint:disable:this identifier_name

    /// The domain that is being blocked.
    public let domain: String

    /// The SHA-256 digest of the domain string.
    public let digest: String

    /// The severity at which the domain is being blocked.
    public let severity: Severity

    /// An optional comment explaining why this instance was blocked.
    public let comment: String?

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case domain, digest, severity, comment
    }
}

// MARK: - Conformances
extension DomainBlock: Hashable {}
