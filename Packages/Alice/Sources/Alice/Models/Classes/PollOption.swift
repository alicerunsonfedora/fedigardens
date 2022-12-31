//
//  PollOption.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// A class representation of a poll option.
public class PollOption: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID for this poll option.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The title for this poll option.
    public let title: String

    /// The number of votes for this option.
    public let votesCount: Int?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        case title
        case votesCount = "votes_count"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension PollOption: Hashable {
    public static func == (lhs: PollOption, rhs: PollOption) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
