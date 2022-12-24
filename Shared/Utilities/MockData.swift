//
//  MockData.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/2/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import Foundation

/// A data structure that houses mock data used for the app.
struct MockData {
    /// Mock data for a status's context.
    /// - Note: The `descendants` property of this mock context can be used for messaging as well.
    static let context: Context? = try! JSONDecoder.decodeFromResource(from: "Context")

    /// Mock data for a private conversation.
    static let conversation: Conversation? = try! JSONDecoder.decodeFromResource(from: "Conversation")

    /// Mock data for a single status.
    static let status: Status? = try! JSONDecoder.decodeFromResource(from: "Status")

    /// Mock data for a timeline (list of statuses).
    static let timeline: [Status]? = try! JSONDecoder.decodeFromResource(from: "Timeline")
}
