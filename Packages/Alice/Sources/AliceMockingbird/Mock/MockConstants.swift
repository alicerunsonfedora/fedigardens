//
//  MockConstants.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/8/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import Foundation

/// A structure that contains common mocked constants.
public struct MockConstants {
    public static var context: Context = MockConstants.named("Context")!
    public static var conversation: Conversation = MockConstants.named("Conversation")!
    public static var poll: Poll = MockConstants.named("Poll")!
    public static var profile: Account = MockConstants.named("Profile")!
    public static var searchResult: SearchResult = MockConstants.named("SearchResult")!
    public static var status: Status = MockConstants.named("Status")!
    public static var timeline: [Status] = MockConstants.named("Timeline")!

    static func named<T: Decodable>(_ resource: String) -> T? {
        guard let path = Bundle.module.path(forResource: resource, ofType: "json") else { return nil }
        let url = URL(filePath: path)
        return try? JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }
}
