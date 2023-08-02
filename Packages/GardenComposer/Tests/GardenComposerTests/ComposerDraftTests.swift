//
//  ComposerDraftTests.swift
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
import XCTest

final class ComposerDraftTests: XCTestCase {
    func testCountMatchesOnRegularText() throws {
        let draft = ComposerDraft(new: "This is some normal text.")
        XCTAssertEqual(draft.count, 25)
    }

    func testCountMatchesWithURL() throws {
        let draft = ComposerDraft(new: "Testing https://www.google.com is that kool")
        XCTAssertEqual(draft.count, 44)
    }

    func testCountMatchesWithAccountMention() throws {
        let draft = ComposerDraft(new: "Let's mention @Gargron@mastodon.social in this reply, shall we?")
        XCTAssertEqual(draft.count, 47)
    }

    func testCountMatchesWithMixedContent() throws {
        let draft = ComposerDraft(new: "Will you check this, please, @Gargron@mastodon.social https://www.google.com")
        XCTAssertEqual(draft.count, 61)
    }
}
