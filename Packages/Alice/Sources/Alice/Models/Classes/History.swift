//
//  History.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A class representation of a tag's history.
public class History: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// The ID associated with this history event.
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The weekday that this history event occurs on.
    public let day: String

    /// The number of times a tag was used on this day.
    public let uses: String

    /// The number of accounts that used this tag on this day.
    public let accounts: String

    // MARK: - COMPUTED PROPERTIES
    enum CodingKeys: String, CodingKey {
        case day
        case uses
        case accounts
    }
}

/// Grants us conformance to `Hashable` for _free_
extension History: Hashable {
    public static func == (lhs: History, rhs: History) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
