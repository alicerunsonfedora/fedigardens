//
//  StatefulFlowProviding.swift
//  FlowKit
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

/// A protocol that provides a stateful flow.
///
/// This protocol is the basis for all flows in FlowKit. Any flows that conform to this protocol must be an actor and
/// provide a safe means of updating state through ``emit(_:)``.
public protocol StatefulFlowProviding: Actor {
    /// The possible states that the flow can encounter.
    ///
    /// This is typically defined as an enum with multiple cases:
    /// ```swift
    /// public enum State: Equatable, Hashable {
    ///     case initial
    ///     case unknown
    ///     case error(String)
    ///
    ///     // ...
    /// }
    /// ```
    ///
    /// - Tip: States should be representative of all the possible paths in a flow, disregarding side effects.
    associatedtype State: Equatable & Hashable

    /// The events that can trigger a change in state.
    associatedtype Event

    /// The current state of the flow.
    ///
    /// The state of a flow can never be modified directly, and it is always updated from an event called with
    /// ``emit(_:)``.
    var state: State { get }

    /// A handler that executes whenever the ``state-swift.property`` is changed.
    ///
    /// - Important: This should never be directly set, but it should be subscribed to using ``subscribe(perform:)``.
    var stateSubscribers: [((State) -> Void)] { get set }

    /// Emits an event asynchronously.
    ///
    /// Emitting events should always result in the ``state-swift.property`` of the flow being changed in some way.
    /// Events cannot produce side effects, as ``State`` will ignore these.
    ///
    /// - Parameter event: The event that will be emitted.
    func emit(_ event: Event) async
}

extension StatefulFlowProviding {
    /// Creates a subscription to a flow's state, performing actions whenever the state changes.
    ///
    /// Typically, this will be used to update SwiftUI views when the view model doesn't provide any information on
    /// its own:
    ///
    /// ```swift
    /// struct SomeFlowView: StatefulView {
    ///     var flow = SomeFlow()
    ///
    ///     var statefulBody: some View {
    ///         Text("Hello, world!")
    ///             .padding()
    ///     }
    ///
    ///     func stateChanged(_ state: FlowProvider.State) {
    ///         switch state { ... }
    ///     }
    /// }
    /// ```
    ///
    /// - Important: ``subscribe(perform:)`` should **never** trigger an event using ``emit(_:)``, as this may cause an
    ///   infinite loop in state changes.
    ///
    /// - Parameter handler: The closure that will be executed whenever ``state-swift.property`` changes.
    public func subscribe(perform handler: @escaping (State) -> Void) {
        self.stateSubscribers.append(handler)
    }

    /// Creates a subscription to a flow's state, performing actions whenever the state changes in a detached task.
    ///
    /// Typically, this will be used to update SwiftUI views when the view model doesn't provide any information on
    /// its own:
    ///
    /// ```swift
    /// struct SomeFlowView: StatefulView {
    ///     var flow = SomeFlow()
    ///
    ///     var statefulBody: some View {
    ///         Text("Hello, world!")
    ///             .padding()
    ///     }
    ///
    ///     func stateChanged(_ state: FlowProvider.State) {
    ///         switch state { ... }
    ///     }
    /// }
    /// ```
    ///
    /// - Important: ``subscribe(perform:)`` should **never** trigger an event using ``emit(_:)``, as this may cause an
    ///   infinite loop in state changes.
    ///
    /// - Parameter handler: The closure that will be executed whenever ``state-swift.property`` changes.
    public func subscribe(perform handler: @escaping (State) async -> Void) {
        let task: ((State) -> Void) = { state in
            Task.detached {
                await handler(state)
            }
        }
        self.stateSubscribers.append(task)
    }
}
