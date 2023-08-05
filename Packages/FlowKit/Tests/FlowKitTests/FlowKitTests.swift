//
//  FlowKitTests.swift
//  FlowKitTests
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import XCTest
@testable import FlowKit

final class FlowKitTests: XCTestCase {
    func testFlowEmits() async throws {
        let flow = DummyFlow()
        await expectState(matches: .initial, in: flow)
        await flow.emit(.enterUnknownState)
        await expectState(matches: .unknown, in: flow)
        await flow.emit(.reset)
        await expectState(matches: .initial, in: flow)
    }

    func testSubscription() async throws {
        var numbers = [Int]()
        let flow = DummyFlow()

        await flow.subscribe { state in
            switch state {
            case .initial:
                numbers.append(1)
            case .unknown:
                numbers.append(0)
            }
        }

        let subscribers = await flow.stateSubscribers
        XCTAssertFalse(subscribers.isEmpty)

        await flow.emit(.enterUnknownState)
        await flow.emit(.reset)

        XCTAssertEqual(numbers, [0, 1])
    }

    func expectState(matches expectation: DummyFlow.State, in flow: DummyFlow) async {
        let state = await flow.state
        XCTAssertEqual(state, expectation)
    }
}
