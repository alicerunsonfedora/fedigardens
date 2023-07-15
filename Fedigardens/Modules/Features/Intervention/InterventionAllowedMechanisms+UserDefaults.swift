//
//  InterventionAllowedMechanism+UserDefaults.swift
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
import GardenSettings
import Interventions

extension InterventionAllowedMechanisms {
    private struct InterventionConstants {
        @GardenSetting(key: .allowsInterventions) static var allowsInterventions = true
        @GardenSetting(key: .intervenesOnRefresh) static var intervenesOnRefresh = true
        @GardenSetting(key: .intervenesOnFetch) static var intervenesOnFetch = true
    }

    @available(*, deprecated, message: "Use InterventionAllowedMechanisms.fromDefaults without any arguments.")
    static func fromDefaults(_ store: UserDefaults = .standard) -> InterventionAllowedMechanisms {
        guard InterventionConstants.allowsInterventions else { return .none }
        var options: InterventionAllowedMechanisms = []
        if InterventionConstants.intervenesOnRefresh {
            options.insert(.refresh)
        }

        if InterventionConstants.intervenesOnFetch {
            options.insert(.fetchMore)
        }

        return options
    }

    static func fromDefaults() -> InterventionAllowedMechanisms {
        guard InterventionConstants.allowsInterventions else { return .none }
        var options: InterventionAllowedMechanisms = []
        if InterventionConstants.intervenesOnRefresh {
            options.insert(.refresh)
        }

        if InterventionConstants.intervenesOnFetch {
            options.insert(.fetchMore)
        }

        return options
    }
}
