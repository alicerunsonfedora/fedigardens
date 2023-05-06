//
//  InterventionHandler.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/22/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Combine
import UIKit

class InterventionHandler: ObservableObject {
    typealias Context = InterventionAuthorizationContext
    @Published var lastInterventionTimeoutDate: Date?
    @Published var currentInterventionContext: Context

    var allowedMechanisms: InterventionAllowedMechanisms {
        InterventionAllowedMechanisms.fromDefaults()
    }

    init(context: InterventionAuthorizationContext = .default) {
        currentInterventionContext = context
    }

    func assignNewContext(_ context: Context) {
        currentInterventionContext = context
        lastInterventionTimeoutDate = .now
    }

    @discardableResult
    func startIntervention(notInstalledErrorHandler: @escaping () -> Void) async -> LayoutState {
        guard let past = lastInterventionTimeoutDate else {
            return await callOneSec(error: notInstalledErrorHandler)
        }
        let timeDifference = Date.now.timeIntervalSince(past)
        if timeDifference > currentInterventionContext.allowedTimeInterval {
            return await callOneSec(error: notInstalledErrorHandler)
        }
        return .loaded
    }

    private func callOneSec(error: @escaping () -> Void) async -> LayoutState {
        guard let oneSec = URL(destination: .oneSec) else { return .loaded }
        if await !UIApplication.shared.canOpenURL(oneSec) {
            DispatchQueue.main.async {
                error()
            }
            return .loaded
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(oneSec)
        }
        return .loaded
    }
}
