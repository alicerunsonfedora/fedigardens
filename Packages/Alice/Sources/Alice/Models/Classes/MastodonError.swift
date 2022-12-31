//
//  MastodonError.swift
//  Chica
//
//  Created by Alex Modroño Vara on 18/7/21.
//

import Foundation

/// Represents an error message.
public class MastodonError: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// Required for being able to iterate through this data model using SwiftUI
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The error message.
    public let error: String

    /*
    *   Optional attributes (all these values must be optionals - i.e all the types must end with `?`-
    *   because the API might not give a value, so they'll be `nil`).
    */

    /// A longer description of the error, mainly provided with the OAuth API.
    public let errorDescription: String?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }

}

/// Grants us conformance to `Hashable` for _free_
extension MastodonError: Hashable {
    public static func == (lhs: MastodonError, rhs: MastodonError) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

