//
//  GardenSetting.swift
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
import Foundation

/// A property wrapper used to access a user default through a Fedigardens settings key.
///
/// This is intended to be used in areas where `AppStorage` cannot be used, such as in a flow or view model:
/// ```swift
/// class MyViewModel {
///     @GardenSetting(key: .loadLimit, maximum: 10)
///     var loadLimit = 10
/// }
/// ```
@propertyWrapper public struct GardenSetting<UserDefaultValue: Decodable> {
    /// The value of the current setting.
    public var value: UserDefaultValue

    /// The key that maps to the value in user defaults.
    public var key: GardenSettingsKey

    /// The default visibility to supply if decoding the value fails.
    var defaultVisibility: PostVisibility = .public

    /// The maximum value that that can be supplied.
    var maximum: Int?

    /// The user defaults store to retrieve and assign settings values to and from.
    var store: UserDefaults = .standard

    public var wrappedValue: UserDefaultValue {
        get {
            if value is Int, let maximum, let storedValue = store.getValue(forKey: key, default: value) as? Int {
                return max(maximum, storedValue) as! UserDefaultValue // swiftlint:disable:this force_cast
            }
            if value is PostVisibility, let storedValue = store.getValue(forKey: key, default: value) as? String {
                // swiftlint:disable:next force_cast
                return (PostVisibility(rawValue: storedValue) ?? defaultVisibility) as! UserDefaultValue
            }
            return store.getValue(forKey: key, default: value)
        }
        set {
            value = newValue
            store.setValue(newValue, forKey: key)
        }
    }

    public var projectedValue: UserDefaultValue { self.value }

    /// Creates a wrapped settings value from user defaults.
    /// - Parameter wrappedValue: The value that will be stored in user defaults.
    /// - Parameter key: The settings key that this value corresponds to.
    /// - Parameter store: The store that will contain the user default. Defaults to the standard suite.
    public init(wrappedValue: UserDefaultValue, key: GardenSettingsKey, store: UserDefaults = .standard) {
        self.value = wrappedValue
        self.key = key
        self.store = store
    }

    /// Creates a wrapped settings value from user defaults, supplying a maximum that the value can reach.
    /// - Parameter wrappedValue: The value that will be stored in user defaults.
    /// - Parameter key: The settings key that this value corresponds to.
    /// - Parameter store: The store that will contain the user default. Defaults to the standard suite.
    /// - Parameter maximum: The maximum value that can be reached for this value.
    public init(wrappedValue: UserDefaultValue,
                key: GardenSettingsKey,
                store: UserDefaults = .standard,
                maximum: Int? = nil) where UserDefaultValue == Int {
        self.value = wrappedValue
        self.key = key
        self.store = store
        self.maximum = maximum
    }

    /// Creates a wrapped settings value from user defaults, supplying a default visibility type if decoding fails.
    /// - Parameter wrappedValue: The value that will be stored in user defaults.
    /// - Parameter key: The settings key that this value corresponds to.
    /// - Parameter store: The store that will contain the user default. Defaults to the standard suite.
    /// - Parameter defaultVisibility: The default visibility if decoding the value fails. Defaults to `.public`.
    public init(wrappedValue: UserDefaultValue,
                key: GardenSettingsKey,
                store: UserDefaults = .standard,
                defaultVisibility: PostVisibility = .public) where UserDefaultValue == PostVisibility {
        self.value = wrappedValue
        self.key = key
        self.store = store
        self.defaultVisibility = defaultVisibility
    }
}
