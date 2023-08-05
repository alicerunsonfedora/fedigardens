//
//  StatefulTestCase.swift
//  FlowKitTestSupport
//
//  Created by Marquis Kurt on 25/6/23.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import FlowKit
import Foundation
import XCTest

/// A subtype of `XCTestCase` that handles testing of flows.
///
/// This protocol can be used to define test cases that test a flow:
/// ```swift
/// import FlowKit
/// import XCTest
///
/// final class ExampleFlowTests: XCTestCase, StatefulTestCase {
///     typealias TestableFlow = ExampleFlow
///
///     var flow: ExampleFlow?
///
///     override func setUp() async throws {
///         flow = ExampleFlow()
///     }
///
///     override func tearDown() async throws {
///         flow = nil
///     }
///
///     func testEmitEvent() async throws { ... }
/// }
/// ```
public protocol StatefulTestCase: XCTestCase {
    /// The flow type that will be tested.
    associatedtype TestableFlow: StatefulFlowProviding

    /// The current instance of the flow.
    ///
    /// - Important: This must be initialized with ``setUp`` and ``tearDown``.
    var flow: TestableFlow? { get set }
}

public extension StatefulTestCase {
    /// Runs a test case function with a pre-checked initialized flow.
    ///
    /// If the flow hasn't been initialized properly in the test's setup, the test the method is called in will fail
    /// automatically, stating that the flow wasn't initialized yet.
    ///
    /// Use this inside a test case function to run your tests, guaranteeing that ``flow`` is present:
    ///
    /// ```swift
    /// func testFlowOperations() async throws {
    ///     try await withCheckedFlow { currentFlow in
    ///         currentFlow.emit(.someEvent)
    ///         XCTAssertEqual(currentFlow.state, .someState)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter task: The task that will be performed after verifying that the flow has been initialized.
    func withCheckedFlow(perform task: @escaping (TestableFlow) async throws -> Void) async rethrows {
        guard let flow else {
            XCTFail("Flow type \(TestableFlow.self) has not been initialized yet.")
            return
        }
        try await task(flow)
    }

    /// Emits an event and waits for a period of time, ensuring that the event has succeeded.
    /// - Parameter event: The event to emit and wait on.
    /// - Parameter time: The time interval that the test will wait for.
    /// - Parameter timeout: The time interval that the test will wait until declaring a failure.
    /// - Parameter message: An optional message for what the test will wait for.
    func emitAndWait(event: TestableFlow.Event,
                     forPeriod time: TimeInterval,
                     timeout: TimeInterval = 10,
                     message: String? = nil) async {
        let expectation = XCTestExpectation(description: message ?? "Event \(event) emitted.")
        await self.flow?.emit(event)
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            expectation.fulfill()
        }
        await self.fulfillment(of: [expectation], timeout: timeout)
    }

    /// Asserts that the flow's current state matches an expected state.
    /// - Parameter expectedState: The expected state that the flow should be in.
    /// - Parameter message: An optional message for the assertion if it fails.
    /// - Parameter file: The file where the call is executed from. This is used to report assertion failures to the
    ///   call site instead of the expectation definition. Defaults to the current file path. (Thanks, Grant!)
    /// - Parameter line: The line where the call is executed from. This is used to report assertion failures to the
    /// call site instead of the expectation definition. Defaults to the current line. (Thanks, Grant!)
    func expectState(matches expectedState: TestableFlow.State,
                     message: String = "",
                     file: StaticString = #filePath,
                     line: UInt = #line) async {
        let state = await self.flow?.state
        XCTAssertEqual(state, expectedState, message, file: file, line: line)
    }

    /// Asserts that the flow's current state doesn't match an expected state.
    /// - Parameter expectedState: The expected state that the flow should not be in.
    /// - Parameter message: An optional message for the assertion if it fails.
    /// - Parameter file: The file where the call is executed from. This is used to report assertion failures to the
    ///   call site instead of the expectation definition. Defaults to the current file path. (Thanks, Grant!)
    /// - Parameter line: The line where the call is executed from. This is used to report assertion failures to the
    ///   call site instead of the expectation definition. Defaults to the current line. (Thanks, Grant!)
    func expectState(doesNotMatch expectedState: TestableFlow.State,
                     message: String = "",
                     file: StaticString = #filePath,
                     line: UInt = #line) async {
        let state = await self.flow?.state
        XCTAssertNotEqual(state, expectedState, message, file: file, line: line)
    }
}
