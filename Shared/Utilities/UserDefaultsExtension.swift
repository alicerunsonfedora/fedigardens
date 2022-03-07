//
//  UserDefaultsExtension.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 22/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

extension UserDefaults {
    /// Whether to show options for passive activities such as likes and reblogs.
    ///
    /// This is intended as an experimental feature to determine if likes and reblogs contribute to the bigger problem
    /// of social media design.
    var showsPassiveActivities: Bool {
        get {
            bool(forKey: "experiments.shows-passive-activities")
        } set {
            set(newValue, forKey: "experiments.shows-passive-activities")
        }
    }
}
