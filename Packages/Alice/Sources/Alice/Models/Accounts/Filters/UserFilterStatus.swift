//
//  UserFilterStatus.swift
//  
//
//  Created by Marquis Kurt on 2/12/23.
//

import Foundation

/// Represents a status that, if matched, should cause its corresponding filter action to be taken.
public struct UserFilterStatus: Codable, Identifiable {
    /// The identifier for this status filter.
    public let id: String

    /// The status ID that will be filtered.
    public let statusId: String

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case statusId = "status_id"
    }
}

extension UserFilterStatus: Hashable {}
