//
//  File.swift
//  File
//
//  Created by Alex Modroño Vara on 16/7/21.
//

import Foundation

/// A class representation of an OAuth token used for authenticating with the API and performing actions.
public struct Token: Codable, Identifiable {
    /// A unique identifier generated for this token.
    public let id = UUID()

    /// The OAuth token to be used for authorization.
    public let accessToken: String

    /// The OAuth token type. Mastodon uses Bearer tokens.
    public let tokenType: String

    /// The OAuth scopes granted by this token, space-separated.
    public let scope: String

    /// When the token was generated.
    public let createdAt: Date

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Token: Hashable {
    public static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
