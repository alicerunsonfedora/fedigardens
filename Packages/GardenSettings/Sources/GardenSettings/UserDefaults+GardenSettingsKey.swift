//
//  UserDefaults+GardensSettingsKey.swift
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

import Foundation

extension UserDefaults {
    /// Retrieves a decoded value from the user defaults store and decodes it. If no value is found, the default vaue is
    /// returned.
    ///
    /// - Parameter key: The settings key to retrieve from user defaults.
    /// - Parameter defaultValue: The default value for this user default if the value was not found in the user defaults
    ///   store.
    func getValue<T: Decodable>(forKey key: GardenSettingsKey, default defaultValue: T) -> T {
        if let value = value(forKey: key) as? T {
            return value
        }
        return defaultValue
    }

    /// Retrieves a value from the user defaults store.
    /// - Parameter key: The settings key to retrieve from user defaults.
    func value(forKey key: GardenSettingsKey) -> Any? {
        return value(forKey: key.rawValue)
    }

    /// Sets a value in the user defaults store with a specified key.
    /// - Parameter value: The value to store into user defaults store.
    /// - Parameter key: The settings key the value will be stored at.
    func setValue(_ value: Any?, forKey key: GardenSettingsKey) {
        setValue(value, forKey: key.rawValue)
    }

}

struct Settings {
    @GardenSetting(key: .loadLimit) var loadLimit: Int = 10
}
