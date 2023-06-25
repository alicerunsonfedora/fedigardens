//
//  FrugalModeFlow.swift
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

import Combine
import FlowKit
import Foundation

/// A flow designed to assess the state of frugal mode in an app.
public class FrugalModeFlow: ObservableObject {
    public enum State {
        /// The initial state of the flow, which indicates nothing has occurred.
        case initial

        /// Frugal mode has been overridden due to environment factors, such as Low Power Mode.
        case overridden

        /// Frugal mode is dictated by what is in the user's defaults.
        case userDefaults
    }

    public enum Event {
        /// Check whether frugal mode will be overridden by environment factors such as Low Poer Mode.
        case checkOverrides

        /// Resets the state of the flow to the initial state.
        case reset
    }

    public var onStateChange: ((State) -> Void)?

    @Published var internalState: State = .initial {
        didSet { onStateChange?(internalState) }
    }

    public init() {}
}

extension FrugalModeFlow: StatefulFlowProviding {
    public var state: State { internalState }
    public func emit(_ event: Event) async {
        switch event {
        case .checkOverrides:
            internalState = ProcessInfo.processInfo.isLowPowerModeEnabled ? .overridden: .userDefaults
        case .reset:
            internalState = .initial
        }
    }
}
