//
//  Application.swift
//  Chica
//
//  Created by Marquis Kurt on 7/7/20.
//

import Foundation

/// A registered service or app with the instance the user interacts with.
public struct Application: Codable, Identifiable {
    /// A unidue identifier generated for this application.
    public let id = UUID()

    /// The name of the application.
    public let name: String

    /// Client ID key, to be used for obtaining OAuth tokens
    public let clientId: String?

    /// Client secret key, to be used for obtaining OAuth tokens
    public let clientSecret: String?

    /// The application's website, if applicable.
    public let website: String?

    /// The application's API key for push streaming, if applicable.
    public let vapidKey: String?

    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case name
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case website
        case vapidKey = "vapid_key"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension Application: Hashable {
    public static func == (lhs: Application, rhs: Application) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
