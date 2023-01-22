//
//  InterventionAllowedMechanism.swift
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

import Foundation

struct InterventionAllowedMechanisms: OptionSet {
    let rawValue: Int
    static let none = InterventionAllowedMechanisms(rawValue: 1 << 0)
    static let refresh = InterventionAllowedMechanisms(rawValue: 1 << 1)
    static let fetchMore = InterventionAllowedMechanisms(rawValue: 1 << 2)
}

extension InterventionAllowedMechanisms {
    static func fromDefaults(_ store: UserDefaults = .standard) -> InterventionAllowedMechanisms {
        guard store.allowsInterventions else { return .none }
        var options: InterventionAllowedMechanisms = []
        if store.intervenesOnRefresh {
            options.insert(.refresh)
        }

        if store.intervenesOnFetch {
            options.insert(.fetchMore)
        }

        return options
    }
}
