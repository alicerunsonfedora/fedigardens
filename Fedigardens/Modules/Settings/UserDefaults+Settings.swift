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
    func getValue<T: Decodable>(forKey key: String, default defaultValue: T) -> T {
        if let value = UserDefaults.standard.value(forKey: key) as? T {
            return value
        }
        return defaultValue
    }

    var showsStatistics: Bool {
        get { bool(forKey: "status.show-statistics") }
        set { set(newValue, forKey: "status.show-statistics") }
    }

    var allowsInterventions: Bool {
        get { getValue(forKey: "health.interventions", default: true) }
        set { set(newValue, forKey: "health.interventions") }
    }

    var intervenesOnRefresh: Bool {
        get { getValue(forKey: "health.interventions.refresh", default: true) }
        set { set(newValue, forKey: "health.interventions.refresh") }
    }

    var intervenesOnFetch: Bool {
        get { getValue(forKey: "health.interventions.fetch", default: true) }
        set { set(newValue, forKey: "health.interventions.fetch") }
    }

    var loadLimit: Int {
        get { max(10, integer(forKey: "network.load-limit")) }
        set { set(newValue, forKey: "network.load-limit") }
    }

    var characterLimit: Int {
        get { getValue(forKey: "author.characterlimit", default: 500) }
        set { set(newValue, forKey: "author.characterlimit") }
    }

    var enforceCharacterLimit: Bool {
        get { getValue(forKey: "author.enforcelimit", default: true) }
        set { set(newValue, forKey: "author.enforcelimit") }
    }
}
