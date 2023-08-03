//
//  ComposerFlowTests.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/8/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import AliceMockingbird
import FlowKitTestSupport
@testable import GardenComposer
import XCTest

class ComposerFlowTests: XCTestCase, StatefulTestCase {
    typealias TestableFlow = ComposerFlow
    var flow: ComposerFlow?

    override func setUp() async throws {
        flow = ComposerFlow(characterLimit: 25)
    }

    override func tearDown() async throws {
        flow = nil
    }

    func testResetEvent() async throws {
        await emitAndWait(event: .reset, forPeriod: 1)
        await expectState(matches: .initial)
    }

    func testStartEvent() async throws {
        let draft = ComposerDraft(new: "")
        await emitAndWait(event: .startDraft(draft), forPeriod: 2, timeout: 5)
        await expectState(matches: .editing(draft))
    }

    func testUpdateContentEvent() async throws {
        let expectedDraft = ComposerDraft(new: "Hello, world!")
        await emitAndWait(event: .startDraft(.init(new: "")), forPeriod: 2, timeout: 5)
        await emitAndWait(event: .updateContent("Hello, world!"), forPeriod: 2, timeout: 5)
        await expectState(matches: .editing(expectedDraft))
    }

    func testAddPollEvent() async throws {
        var expectedDraft = ComposerDraft(new: "")
        await emitAndWait(event: .startDraft(.init(new: "")), forPeriod: 2, timeout: 5)
        expectedDraft.poll = .init(options: ["", ""], expirationDate: Date.now.advanced(by: 300))
        await emitAndWait(event: .addPoll, forPeriod: 2, timeout: 5)
        await expectState(matches: .editing(expectedDraft))
    }

    func testAddPollOptionEvent() async throws {
        var expectedDraft = ComposerDraft(new: "")
        await emitAndWait(event: .startDraft(.init(new: "")), forPeriod: 2, timeout: 5)
        expectedDraft.poll = .init(options: ["", "", "Test"], expirationDate: Date.now.advanced(by: 300))
        await emitAndWait(event: .addPoll, forPeriod: 2, timeout: 5)
        await emitAndWait(event: .addPollOption("Test"), forPeriod: 2, timeout: 5)
        await expectState(matches: .editing(expectedDraft))
    }

    func testPublishEvent() async throws {
        let draft = ComposerDraft(new: "Hello, world!")
        await emitAndWait(event: .startDraft(draft), forPeriod: 2, timeout: 5)
        await emitAndWait(event: .publish, forPeriod: 5, timeout: 10)
        await expectState(matches: .published)
    }

    func testPublishErrorsWithoutDraft() async throws {
        await emitAndWait(event: .publish, forPeriod: 5, timeout: 10)
        await expectState(matches: .errored(.noDraftSupplied))
    }

    func testPublishErrorsExceedingCharacterLimit() async throws {
        let draft = ComposerDraft(new: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        await emitAndWait(event: .startDraft(draft), forPeriod: 2, timeout: 5)
        await emitAndWait(event: .publish, forPeriod: 5, timeout: 10)
        await expectState(matches: .errored(.exceedsCharacterLimit))
    }
}
