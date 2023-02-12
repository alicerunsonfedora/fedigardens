//
//  Field.swift
//  Chica
//
//  Created by Alejandro Modroño Vara on 07/07/2020.
//

import Foundation

/// Represents a profile field as a name-value pair with optional verification.
public struct Field: Codable, Identifiable {
    /// A unique identifier generated for this field.
    public let id = UUID()

    /// The key of a given field's key-value pair.
    public let name: String

    /// The value associated with the name key.
    public let value: String

    /// An ISO-8601 date string of when the URL was verified.
    public let verifiedAt: String?

    // MARK: - Coding Keys
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
