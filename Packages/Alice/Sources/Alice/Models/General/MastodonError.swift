//
//  MastodonError.swift
//  Chica
//
//  Created by Alex Modroño Vara on 18/7/21.
//

import Foundation

/// Represents an error message.
public struct MastodonError: Codable, Identifiable {
    /// A unique identifier for this error.
    public let id = UUID()

    /// The error message.
    public let error: String

    /// A longer description of the error, mainly provided with the OAuth API.
    public let errorDescription: String?

    // MARK: - Coding Keys

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
