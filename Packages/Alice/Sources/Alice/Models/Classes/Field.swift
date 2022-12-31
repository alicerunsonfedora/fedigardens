//
//  Field.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents a profile field as a name-value pair with optional verification.
public class Field: Codable, Identifiable {

    // MARK: - STORED PROPERTIES

    /// Required for being able to iterate through this data model using SwiftUI
    // swiftlint:disable:next identifier_name
    public let id = UUID()

    /// The key of a given field's key-value pair.
    public let name: String

    /// The value associated with the name key.
    public let value: String

    /*
    *   Optional attributes (all these values must be optionals - i.e all the types must end with `?`-
    *   because the API might not give a value, so they'll be `nil`).
    */

    /**
    *   Timestamp of when the server verified a URL value for a rel="me” link.
    *   Type: String (ISO 8601 Datetime) if value is a verified URL. Otherwise, null
    */
    public let verifiedAt: String?

    // MARK: - COMPUTED PROPERTIES

    private enum CodingKeys: String, CodingKey {
        case name
        case value
        case verifiedAt = "verified_at"
    }

}

/// Grants us conformance to `Hashable` for _free_
extension Field: Hashable {
    public static func == (lhs: Field, rhs: Field) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
