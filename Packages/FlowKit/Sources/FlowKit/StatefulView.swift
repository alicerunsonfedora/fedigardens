//
//  StatefulView.swift
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

import SwiftUI

/// A SwiftUI view with a flow provider.
public protocol StatefulView: View {
    /// The flow that the view follows.
    associatedtype FlowProvider: StatefulFlowProviding

    /// The body type of this view.
    /// - SeeAlso: ``SwiftUI/View/body``
    associatedtype StatefulBody: View

    /// The primary contents of this view that will subscribe to events.
    @ViewBuilder var statefulBody: Self.StatefulBody { get }

    /// The current flow that the view has.
    var flow: FlowProvider { get set }

    /// A callback method that executes whenever the state of the current flow changes.
    ///
    /// When the SwiftUI view first appears, the ``flow`` subscribes to this method.
    ///
    /// - Parameter state: The current state of the flow to perform actions on.
    func stateChanged(_ state: FlowProvider.State)
}

extension View where Self: StatefulView {
    public var body: some View {
        statefulBody
            .onAppear {
                flow.subscribe(perform: stateChanged)
            }
    }
}
