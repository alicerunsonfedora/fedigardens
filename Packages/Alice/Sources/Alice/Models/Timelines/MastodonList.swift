//
//  MastodonList.swift
//  Chica
//
//  Created by Marquis Kurt on 12/29/22.
//

import Foundation

/// A list that contains statuses that the user collected.
public struct MastodonList: Codable, Identifiable {
    /// Which replies should be shown in the list.
    public enum ReplyPolicy: String, Codable {
        case followed, list, none
    }

    /// The list's ID.
    public let id: String // swiftlint:disable:this identifier_name

    /// The name of the list.
    public let title: String

    /// The policy that dicatates what kinds of replies will be diplayed in the list.
    public let repliesPolicy: ReplyPolicy

    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id // swiftlint:disable:this identifier_name
        case title
        case repliesPolicy = "replies_policy"
    }
}

/// Grants us conformance to `Hashable` for _free_
extension MastodonList: Hashable {
    public static func == (lhs: MastodonList, rhs: MastodonList) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
