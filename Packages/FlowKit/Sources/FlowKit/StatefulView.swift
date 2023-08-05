//
//  StatefulView.swift
//  FlowKit
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// A SwiftUI view that can be hooked up with a flow provider.
///
/// These views are used to react to changes based on a flow's given state. The main body of the view is defined in
/// ``statefulBody-swift.property``, and any changes to the flow's state triggers the ``stateChanged(_:)`` method in
/// the view.
///
/// - Important: Do not override the view's ``SwiftUI/View/body``. The view is already set up to subscribe to its
///   flow's changes through ``StatefulFlowProviding/subscribe(perform:)``.
public protocol StatefulView: View {

    /// The flow type that the view follows.
    associatedtype FlowProvider: StatefulFlowProviding

    /// The body type of this view.
    ///
    /// This is specified to provide ``statefulBody-swift.property``'s type to SwiftUI.
    ///
    /// - SeeAlso: ``SwiftUI/View/body``
    associatedtype StatefulBody: View

    /// The primary contents of this view that will subscribe to events.
    ///
    /// Contents of the view that are normally defined in ``SwiftUI/View/body`` should be defined here, as the main
    /// body will auto-register changes to the flow's state with ``stateChanged(_:)``.
    @ViewBuilder var statefulBody: Self.StatefulBody { get }

    /// The current flow that the view has.
    var flow: FlowProvider { get set }

    /// A callback method that executes whenever the state of the current flow changes.
    ///
    /// When the SwiftUI view first appears, the ``flow`` subscribes to this method.
    ///
    /// - SeeAlso: ``StatefulFlowProviding/subscribe(perform:)``.
    /// - Important: ``stateChanged(_:)`` should **never** trigger an event using ``StatefulFlowProviding/emit(_:)``,
    ///   as this may cause an infinite loop in state changes.
    ///
    /// - Parameter state: The current state of the flow to perform actions on.
    func stateChanged(_ state: FlowProvider.State)
}

extension View where Self: StatefulView {
    public var body: some View {
        statefulBody
            .onAppear {
                Task {
                    await flow.subscribe(perform: stateChanged)
                }
            }
    }
}
