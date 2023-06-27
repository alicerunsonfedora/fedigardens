//
//  InterventionRequestError.swift
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

import Foundation

/// An enumeration representing the various errors that can occur when requesting an intervention.
public enum InterventionRequestError: Error {
    /// one sec is not installed on the device.
    case oneSecNotAvailable

    /// A request has already been made.
    case requestAlreadyMade(Date)

    /// An authorization request was made from an invalid state.
    ///
    /// This usually occurs when the request was made in its initial state, or if the request was made after it
    /// encountered an error.
    case invalidAuthorizationFlowState

    /// The user has already authorized the action, and no further action is needed.
    case alreadyAuthorized(Date, context: InterventionAuthorizationContext)
}

extension InterventionRequestError: Equatable {
    public static func == (lhs: InterventionRequestError, rhs: InterventionRequestError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
}
