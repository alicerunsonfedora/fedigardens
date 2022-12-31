//
//  ReplyPolicy.swift
//  Chica
//
//  Created by Marquis Kurt on 12/29/22.
//

import Foundation

/// Which replies should be shown in the list.
public enum ReplyPolicy: String, Codable {
    /// Show replies to any followed user.
    case followed

    /// Show replies to members of the list.
    case list

    /// Show replies to no one.
    case none
}
