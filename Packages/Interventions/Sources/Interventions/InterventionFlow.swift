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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A flow that manages interventions in an app.
///
/// This flow is commonly used to provide interventions to have a user reflect and confirm that they want to perform
/// the action that triggered the intervention. This works hand-in-hand with [one sec](https://one-sec.app) to provide
/// intervention exercises.
public class InterventionFlow<Opener: InterventionLinkOpener>: ObservableObject {
    public enum State: Equatable, Hashable {
        /// The initial state of the flow, where no interventions have been requested.
        case initial

        /// An intervention was requested at a specific date and time.
        case requestedIntervention(Date)

        /// An intervention was authorized by the user at a specific date and time.
        case authorizedIntervention(Date, context: InterventionAuthorizationContext)

        /// An error has occurred.
        case error(Error)

        public static func == (lhs: State, rhs: State) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
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

    public var onStateChange: ((State) -> Void)?

    @Published var internalState: State = .initial {
        didSet { onStateChange?(internalState) }
    }

    private let oneSecUrl = URL(string: "onesec://reintervene?appId=fedigardens")!
    var opener: Opener

    #if os(macOS)
    /// Creates an intervention flow with a link opener.
    /// - Parameter linkOpener: The actor that will open links to call one sec. Default is `NSWorkspace.shared`.
    public init(linkOpener: Opener = NSApplication.shared) {
        self.opener = linkOpener
    }
    #else
    /// Creates an intervention flow with a link opener.
    /// - Parameter linkOpener: The actor that will open links to call one sec. Default is `UIApplication.shared`.
    public init(linkOpener: Opener = UIApplication.shared) {
        self.opener = linkOpener
    }
    #endif

    func requestIntervention(startTime: Date) async {
        if case .authorizedIntervention(let date, let context) = internalState,
           Date.now.timeIntervalSince(date) <= context.allowedTimeInterval {
            return
        }
        if case .requestedIntervention(let date) = internalState {
            await assignState(.error(InterventionRequestError.requestAlreadyMade(date)))
            return
        }
        guard await opener.canOpenURL(oneSecUrl) else {
            await assignState(.error(InterventionRequestError.oneSecNotAvailable))
            return
        }
        await opener.open(oneSecUrl)
        await assignState(.requestedIntervention(startTime))
    }

    func authorizeIntervention(startTime: Date, context: InterventionAuthorizationContext) async {
        switch internalState {
        case .initial:
            await assignState(.error(InterventionRequestError.invalidAuthorizationFlowState))
        case .requestedIntervention:
            internalState = .authorizedIntervention(startTime, context: context)
        case .authorizedIntervention(let date, let context):
            await assignState(.error(InterventionRequestError.alreadyAuthorized(date, context: context)))
        case .error:
            return
        }
    }

    func assignState(_ newState: State) async {
        DispatchQueue.main.async { [weak self] in
            self?.internalState = newState
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
