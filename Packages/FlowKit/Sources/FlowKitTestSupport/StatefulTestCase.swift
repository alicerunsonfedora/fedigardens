//
//  StatefulTestCase.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 25/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

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
}
