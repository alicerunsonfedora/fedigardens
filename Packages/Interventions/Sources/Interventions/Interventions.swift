//
//  InterventionFlow.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 26/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import FlowKit

public class InterventionFlow {
    public enum State {
        case initial
    }

    public enum Event {
        case reset
    }

    public var onStateChange: ((State) -> Void)?
    var internalState: State = .initial {
        didSet { onStateChange?(internalState) }
    }

    public init() {}
}

extension InterventionFlow: StatefulFlowProviding {
    public var state: State { internalState }

    public func emit(_ event: Event) async {

    }
}
