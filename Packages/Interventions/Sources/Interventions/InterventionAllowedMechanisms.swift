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
public struct InterventionAllowedMechanisms: OptionSet {
    public var rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// No interventions can occur.
    public static let none = InterventionAllowedMechanisms(rawValue: 1 << 0)

    /// Presents an intervention when refreshing content.
    public static let refresh = InterventionAllowedMechanisms(rawValue: 1 << 1)

    /// Presents an intervention when requesting for more content.
    public static let fetchMore = InterventionAllowedMechanisms(rawValue: 1 << 2)

    /// Presents an intervention at all possible opportunities.
    public static let all: InterventionAllowedMechanisms = [.refresh, .fetchMore]
}
