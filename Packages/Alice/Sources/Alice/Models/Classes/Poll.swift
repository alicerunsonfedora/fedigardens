//
//  Poll.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A class representation of a poll.
public class Poll: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID for this poll registered with the server.
    // swiftlint:disable:next identifier_name
    public let id: String

    /// The exipration date for this poll.
    public let expiresAt: String?

    /// Whether the poll has expired.
    public let expired: Bool

    /// Whether the poll supports selecting multiple options.
    public let multiple: Bool

    /// The number of total votes on this poll.
    public let votesCount: Int

    /// The options listed for this poll.
    public let options: [PollOption]

    /// Whether the user has voted on this poll.
    public let voted: Bool?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        // swiftlint:disable:next identifier_name
        case id
        case expiresAt = "expires_at"
        case expired
        case multiple
        case votesCount = "votes_count"
        case options
        case voted
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Poll: Hashable {
    public static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
