//
//  AuthorViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/21/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

@testable import Fedigardens
import XCTest

class ShoutAuthorViewModelTests: XCTestCase {
    var viewModel: AuthorViewModel?

    override func setUpWithError() throws {
        self.viewModel = AuthorViewModel()
    }

    override func tearDownWithError() throws {
        self.viewModel = nil
    }

    func testCharacterLimitCount() throws {
        let normalTextCase = "This is some normal text"
        try assertViewModelTextMatches(count: 476, with: normalTextCase)

        let linkTextCase = "Testing https://www.google.com is that kool"
        try assertViewModelTextMatches(count: 456, with: linkTextCase)

        let mentionTextCase = "Let's mention @Gargron@mastodon.social in this reply, shall we?"
        try assertViewModelTextMatches(count: 453, with: mentionTextCase)

        let mixedTextCase = "Will you check this, please, @Gargron@mastodon.social https://www.google.com"
        try assertViewModelTextMatches(count: 439, with: mixedTextCase)
    }

    private func assertViewModelTextMatches(count: Int, with text: String) throws {
        guard let viewModel else {
            XCTFail("View model not instantiated.")
            return
        }
        viewModel.text = text
        XCTAssertEqual(viewModel.charactersRemaining, count)
    }
}
