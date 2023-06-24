//
//  FlowKitTests.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import XCTest
@testable import FlowKit

final class FlowKitTests: XCTestCase {
    func testFlowEmits() async throws {
        let flow = DummyFlow()
        XCTAssertEqual(flow.state, .initial)
        await flow.emit(.enterUnknownState)
        XCTAssertEqual(flow.state, .unknown)
        await flow.emit(.reset)
        XCTAssertEqual(flow.state, .initial)
    }

    func testSubscription() async throws {
        var numbers = [Int]()
        let flow = DummyFlow()
        flow.subscribe { state in
            switch state {
            case .initial:
                numbers.append(1)
            case .unknown:
                numbers.append(0)
            }
        }

        XCTAssertNotNil(flow.onStateChange)

        await flow.emit(.enterUnknownState)
        await flow.emit(.reset)

        XCTAssertEqual(numbers, [0, 1])
    }
}
