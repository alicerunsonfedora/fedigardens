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
import Foundation

public class InterventionFlow {
    public enum State: Equatable, Hashable {
        case initial
        case requestedIntervention(Date)
        case authorizedIntervention(Date, context: InterventionAuthorizationContext)
        case interventionTimedOut

        public static func == (lhs: State, rhs: State) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .initial:
                hasher.combine("\(State.self)__initial")
            case .requestedIntervention(let date):
                hasher.combine("\(State.self)__requestedIntervention")
                hasher.combine(date.timeIntervalSince1970)
            case .authorizedIntervention(let date, let context):
                hasher.combine("\(State.self)__authorizedIntervention")
                hasher.combine(date.timeIntervalSince1970)
                hasher.combine(context)
            case .interventionTimedOut:
                hasher.combine("\(State.self)__interventionTimedOut")
            }
        }
    }

    public enum Event {
        case requestIntervention
        case authorizeIntervention(Date, context: InterventionAuthorizationContext)
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
