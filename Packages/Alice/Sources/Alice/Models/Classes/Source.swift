//
//  Source.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/**
*   Represents display or publishing preferences of user's own account.
*   Returned as an additional entity when verifying and updated credentials, as an attribute of Account.
*/
public class Source: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// Required for being able to iterate through this data model using SwiftUI
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The profile's bio / description.
    public let note: String

    /// Metadata about the account.
    public let fields: [Field]

    /*
    *   Optional attributes (all these values must be optionals - i.e all the types must end with `?`-
    *   because the API might not give a value, so they'll be `nil`).
    */

    /// The default post privacy to be used for new statuses.
    public let privacy: String?

    /// Whether new statuses should be marked sensitive by default.
    public let sensitive: Bool?

    /// The default posting language for new statuses.
    public let language: Bool?

    /// The number of pending follow requests.
    public let followRequestsCount: Int?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        case note
        case fields
        case privacy
        case sensitive
        case language
        case followRequestsCount = "follow_requests_count"
    }

}

/// Grants us conformance to `Hashable` for _free_
extension Source: Hashable {
    public static func == (lhs: Source, rhs: Source) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
