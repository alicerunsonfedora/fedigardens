//
//  StatefulFlowProviding+TestHelpers.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 26/4/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import FlowKit
import XCTest

extension StatefulFlowProviding {
    /// Asserts that the flow's current state matches an expected state.
    /// - Parameter expectedState: The expected state that the flow should be in.
    /// - Parameter message: An optional message for the assertion if it fails.
    public func expectState(matches expectedState: State, message: String = "") {
        XCTAssertEqual(self.state, expectedState, message)
    }

    /// Asserts that the flow's current state doesn't match an expected state.
    /// - Parameter expectedState: The expected state that the flow should not be in.
    /// - Parameter message: An optional message for the assertion if it fails.
    public func expectState(doesntMatch expectedState: State, message: String = "") {
        XCTAssertNotEqual(self.state, expectedState, message)
    }

    /// Emits an event and waits for a period of time, ensuring that the event has succeeded.
    /// - Parameter event: The event to emit and wait on.
    /// - Parameter waiter: The test case that will wait on the event to finish emitting.
    /// - Parameter time: The time interval that the test will wait for.
    /// - Parameter timeout: The time interval that the test will wait until declaring a failure.
    /// - Parameter message: An optional message for what the test will wait for.
    public func emitAndWait(event: Event,
                            in waiter: XCTestCase,
                            forPeriod time: TimeInterval,
                            timeout: TimeInterval = 10,
                            message: String? = nil) async {
        let expectation = XCTestExpectation(description: message ?? "Event \(event) emitted.")
        await self.emit(event)
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            expectation.fulfill()
        }
        await waiter.fulfillment(of: [expectation], timeout: timeout)
    }
}
