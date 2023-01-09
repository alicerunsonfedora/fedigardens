//
//  UserDefaults+Settings.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 22/2/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

extension UserDefaults {
    var showsStatistics: Bool {
        get { bool(forKey: "status.show-statistics") }
        set { set(newValue, forKey: "status.show-statistics") }
    }

    var allowsInterventions: Bool {
        get {
            if UserDefaults.standard.value(forKey: "health.interventions") == nil {
                return true
            }
            return bool(forKey: "health.interventions")
        }
        set { set(newValue, forKey: "health.interventions") }
    }

    var loadLimit: Int {
        get { max(10, integer(forKey: "network.load-limit")) }
        set { set(newValue, forKey: "network.load-limit") }
    }
}
