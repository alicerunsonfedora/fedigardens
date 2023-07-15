//
//  AppStorage+GardensSettingsKey.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 15/7/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import SwiftUI

// NOTE: Thanks to implementation from Swapnanil Dhol on their Medium article.
// https://swapnanildhol.medium.com/safer-and-cleaner-userdefaults-and-appstorage-23f22d989fcc
/// An extension that provides access to preferences defined by keys in ``GardensSettingsKey``.
public extension AppStorage {

    /// Creates a wrapper to a user defaults setting on a specified Fedigardens key.
    /// - Parameter value: The value containing the user default.
    /// - Parameter key: The ``GardensSettingsKey`` that the value derives from.
    /// - Parameter store: The user defaults store where this key is found, if not in the standard bundle.
    init(wrappedValue: Value, _ key: GardenSettingsKey, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    /// Creates a wrapper to a user defaults setting on a specified Fedigardens key.
    /// - Parameter value: The value containing the user default.
    /// - Parameter key: The ``GardensSettingsKey`` that the value derives from.
    /// - Parameter store: The user defaults store where this key is found, if not in the standard bundle.
    init(wrappedValue: Value, _ key: GardenSettingsKey, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    /// Creates a wrapper to a user defaults setting on a specified Fedigardens key.
    /// - Parameter value: The value containing the user default.
    /// - Parameter key: The ``GardensSettingsKey`` that the value derives from.
    /// - Parameter store: The user defaults store where this key is found, if not in the standard bundle.
    init(wrappedValue: Value, _ key: GardenSettingsKey, store: UserDefaults? = nil) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    /// Creates a wrapper to a user defaults setting on a specified Fedigardens key.
    /// - Parameter value: The value containing the user default.
    /// - Parameter key: The ``GardensSettingsKey`` that the value derives from.
    /// - Parameter store: The user defaults store where this key is found, if not in the standard bundle.
    init(wrappedValue: Value, _ key: GardenSettingsKey, store: UserDefaults? = nil) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    /// Creates a wrapper to a user defaults setting on a specified Fedigardens key.
    /// - Parameter value: The value containing the user default.
    /// - Parameter key: The ``GardensSettingsKey`` that the value derives from.
    /// - Parameter store: The user defaults store where this key is found, if not in the standard bundle.
    init(wrappedValue: Value, _ key: GardenSettingsKey, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    /// Creates a wrapper to a user defaults setting on a specified Fedigardens key.
    /// - Parameter value: The value containing the user default.
    /// - Parameter key: The ``GardensSettingsKey`` that the value derives from.
    /// - Parameter store: The user defaults store where this key is found, if not in the standard bundle.
    init(wrappedValue: Value, _ key: GardenSettingsKey, store: UserDefaults? = nil) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    /// Creates a wrapper to a user defaults setting on a specified Fedigardens key.
    /// - Parameter value: The value containing the user default.
    /// - Parameter key: The ``GardensSettingsKey`` that the value derives from.
    /// - Parameter store: The user defaults store where this key is found, if not in the standard bundle.
    init(wrappedValue: Value, _ key: GardenSettingsKey, store: UserDefaults? = nil) where Value == PostVisibility {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
