//
//  InterventionAllowedMechanism.swift
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

/// The set of allowed cases for which an intervention can occur.
@OptionSet<UInt8>
public struct InterventionAllowedMechanisms {
    private enum Options: Int {
        /// An intervention can never occur.
        case none

        /// An intervention occurs whenever a refresh action is committed.
        case refresh

        /// An interventions occurs whenever a fetch action is commited.
        case fetchMore
    }
}
