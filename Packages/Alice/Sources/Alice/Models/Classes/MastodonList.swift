//
//  MastodonList.swift
//  Chica
//
//  Created by Marquis Kurt on 12/29/22.
//

import Foundation

public class MastodonList: Codable, Identifiable {
    public let id: String
    public let title: String
    public let repliesPolicy: ReplyPolicy

    // MARK: - COMPUTED PROPERTIES
    private enum CodingKeys: String, CodingKey {
        case id
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
