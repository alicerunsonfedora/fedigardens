//
//  ReplyMentionsTests.swift
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

@testable import GardenComposer
import Alice
import XCTest
import AliceMockingbird

final class ReplyMentionsTests: XCTestCase {
    let allAccounts = MockConstants.timeline.flatMap { status in
        var accounts = [status.account]
        if let reblogged = status.reblog {
            accounts.append(reblogged.account)
        }
        return accounts
    }

    func testReplyMentionsOnSelfThread() throws {
        let reply = MockConstants.status.replyMentions(excluding: MockConstants.profile)
        XCTAssertEqual(reply, "")
    }

    func testReplyMentionsInConversation() throws {
        let nonUniqueAccount = allAccounts.first { account in account != MockConstants.profile }
        let reply = MockConstants.status.replyMentions(excluding: nonUniqueAccount!)
        XCTAssertEqual(reply, "@admin")
    }
}
