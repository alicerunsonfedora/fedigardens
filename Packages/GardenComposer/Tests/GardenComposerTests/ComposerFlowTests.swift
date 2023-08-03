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

final class ComposerFlowTests: XCTestCase, StatefulTestCase {
    typealias TestableFlow = ComposerFlow
    var flow: ComposerFlow?

    override func setUp() async throws {
        let mock = AliceMockKeychain()
        let provider = Alice(using: AliceMockSession.self, with: .init(using: mock))
        flow = ComposerFlow(characterLimit: 25, provider: provider)
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

    func testUpdatePollEvent() async throws {
        let initialPoll = ComposerDraftPoll(options: ["Hello", "World"], expirationDate: .now.advanced(by: 300))
        let expectedDraft = ComposerDraft(content: "Hello, world!", poll: initialPoll)
        await emitAndWait(event: .startDraft(.init(new: "Hello, world!")), forPeriod: 2, timeout: 5)
        await emitAndWait(event: .updatePoll(initialPoll), forPeriod: 2, timeout: 5)
        await expectState(matches: .editing(expectedDraft))
    }

    func testUpdateLocalizationEvent() async throws {
        var expectedDraft = ComposerDraft(new: "Hello, world!")
        expectedDraft.localizationCode = "fr"
        await emitAndWait(event: .startDraft(.init(new: "Hello, world!")), forPeriod: 2, timeout: 5)
        await emitAndWait(event: .updateLocalizationCode("fr"), forPeriod: 2, timeout: 5)
        await expectState(matches: .editing(expectedDraft))
    }

    func testUpdateVisibilityEvent() async throws {
        let expectedDraft = ComposerDraft(new: "Hello, world!", visibility: .direct)
        await emitAndWait(event: .startDraft(.init(new: "Hello, world!")), forPeriod: 2, timeout: 5)
        await emitAndWait(event: .updateVisibility(.direct), forPeriod: 2, timeout: 5)
        await expectState(matches: .editing(expectedDraft))
    }

    func testUpdateContentWarningEvent() async throws {
        var expectedDraft = ComposerDraft(new: "Hello, world!")
        expectedDraft.containsSensitiveInformation = true
        expectedDraft.sensitiveDisclaimer = "Uh oh"
        await emitAndWait(event: .startDraft(.init(new: "Hello, world!")), forPeriod: 2, timeout: 5)
        await emitAndWait(event: .updateContentWarning(true, message: "Uh oh"), forPeriod: 2, timeout: 5)
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

    func testUpdateEventErrorsWithNoDraft() async throws {
        await emitAndWait(event: .updateContentWarning(true, message: "How did I get here?"), forPeriod: 2, timeout: 5)
        await expectState(matches: .errored(.unsupportedEventDispatch))
    }
}
