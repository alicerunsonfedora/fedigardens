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
    associatedtype State: Equatable & Hashable

    /// The events that can trigger a change in state.
    associatedtype Event

    /// The current state of the flow.
    var state: State { get }

    /// A handler that executes whenever the ``state-swift.property`` is changed.
    var onStateChange: ((State) -> Void)? { get set }

    /// Emits an event asynchronously.
    /// - Parameter event: The event that will be emitted.
    func emit(_ event: Event) async
}

extension StatefulFlowProviding {
    /// Creates a subscription to a flow's state, performing actions whenever the state changes.
    ///
    /// Typically, this will be used to update SwiftUI views when the view model doesn't provide any information on its own.
    ///
    /// - Parameter handler: The closure that will be executed whenever ``state-swift.property`` changes.
    public func subscribe(perform handler: @escaping (State) -> Void) {
        self.onStateChange = handler
    }
}
