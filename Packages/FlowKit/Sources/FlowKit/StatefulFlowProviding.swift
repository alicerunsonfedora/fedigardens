//
//  StatefulFlowProviding.swift
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

/// A protocol that provides a stateful flow.
///
/// This is the basis for most view models that follow this approach.
public protocol StatefulFlowProviding: AnyObject {
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
    var onStateChange: ((State) -> Void)? { get set }

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
        self.onStateChange = handler
    }
}
