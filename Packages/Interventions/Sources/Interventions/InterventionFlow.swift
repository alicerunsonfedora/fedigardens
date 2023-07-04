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

import Combine
import FlowKit
import Foundation

/// A flow that manages interventions in an app.
///
/// This flow is commonly used to provide interventions to have a user reflect and confirm that they want to perform
/// the action that triggered the intervention. This works hand-in-hand with [one sec](https://one-sec.app) to provide
/// intervention exercises.
public actor InterventionFlow<Opener: InterventionLinkOpener>: ObservableObject {
    public enum State: Equatable, Hashable {
        /// The initial state of the flow, where no interventions have been requested.
        case initial

        /// An intervention was requested at a specific date and time.
        case requestedIntervention(Date)

        /// An intervention was authorized by the user at a specific date and time.
        case authorizedIntervention(Date, context: InterventionAuthorizationContext)

        /// An error has occurred.
        case error(InterventionRequestError)

        nonisolated public static func == (lhs: State, rhs: State) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }

        nonisolated public func hash(into hasher: inout Hasher) {
            switch self {
            case .initial:
                hasher.combine("\(State.self)__initial")
            case .requestedIntervention(let date):
                hasher.combine("\(State.self)__requestedIntervention")
                hasher.combine(date.ISO8601Format())
            case .authorizedIntervention(let date, let context):
                hasher.combine("\(State.self)__authorizedIntervention")
                hasher.combine(date.ISO8601Format())
                hasher.combine(context)
            case .error(let error):
                hasher.combine(error.localizedDescription)
            }
        }
    }

    public enum Event {
        /// Requests an intervention.
        case requestIntervention

        /// Authorized the currently requested intervention at a specific date with a context.
        case authorizeIntervention(Date, context: InterventionAuthorizationContext)

        /// Resets the flow to its initial state.
        case reset
    }

    public var stateSubscribers = [((State) -> Void)]()

    var internalState: State = .initial {
        didSet {
            stateSubscribers.forEach { callback in
                callback(internalState)
            }
        }
    }

    private let oneSecUrl = URL(string: "onesec://reintervene?appId=fedigardens")!
    var opener: Opener

    /// Creates an intervention flow with a link opener.
    /// - Parameter linkOpener: The actor that will open links to call one sec.
    public init(linkOpener: Opener) {
        self.opener = linkOpener
    }

    func requestIntervention(startTime: Date) async {
        if case .authorizedIntervention(let date, let context) = internalState,
           Date.now.timeIntervalSince(date) <= context.allowedTimeInterval {
            return
        }
        if case .requestedIntervention(let date) = internalState {
            self.internalState = .error(InterventionRequestError.requestAlreadyMade(date))
            return
        }
        guard await opener.canOpenURL(oneSecUrl) else {
            self.internalState = .error(InterventionRequestError.oneSecNotAvailable)
            return
        }
        await opener.open(oneSecUrl)
        self.internalState = .requestedIntervention(startTime)
    }

    func authorizeIntervention(startTime: Date, context: InterventionAuthorizationContext) async {
        switch internalState {
        case .initial:
            self.internalState = .error(InterventionRequestError.invalidAuthorizationFlowState)
        case .requestedIntervention:
            internalState = .authorizedIntervention(startTime, context: context)
        case .authorizedIntervention(let date, let context):
            self.internalState = .error(InterventionRequestError.alreadyAuthorized(date, context: context))
        case .error:
            return
        }
    }
}

extension InterventionFlow: StatefulFlowProviding {
    public var state: State { internalState }

    public func emit(_ event: Event) async {
        switch event {
        case .requestIntervention:
            await requestIntervention(startTime: .now)
        case .authorizeIntervention(let date, let context):
            await authorizeIntervention(startTime: date, context: context)
        case .reset:
            internalState = .initial
        }
    }
}
