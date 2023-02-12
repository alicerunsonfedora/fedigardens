//
//  FamiliarFollowers.swift
//  
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// A subset of accounts that two users follow in common.
public struct FamiliarFollowers: Codable, Identifiable {
    /// The ID of the account that shares followers with the current user.
    public let id: String

    /// The list of accounts that the current user and account share.
    public let accounts: [Account]

    private enum CodingKeys: String, CodingKey {
        case id, accounts
    }
}

extension FamiliarFollowers: Hashable {}
