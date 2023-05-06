//
//  GardensSettingsKey.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/21/23.
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
import UIKit

enum GardensSettingsKey: String {
    case loadLimit = "network.load-limit"
    case showsStatistics = "status.shows-statistics"
    case useFocusedInbox = "timeline.original-filter"
    case alwaysShowUserHandle = "timeline.show-handles"
    case allowsInterventions = "health.interventions"
    case intervenesOnRefresh = "health.interventions.refresh"
    case intervenesOnFetch = "health.interventions.fetch"
    case characterLimit = "author.characterlimit"
    case enforceCharacterLimit = "author.enforcelimit"
    case defaultVisibility = "author.defaultvisibility"
    case defaultReplyVisibility = "author.replyvisibility"
    case defaultQuoteVisibility = "author.quotevisibility"
    case defaultFeedbackVisibility = "author.feedbackvisibility"
    case addQuoteParticipant = "author.quoteparticipant"
    case preferMatrixConversations = "profiles.prefermatrix"
    case frugalMode = "core.frugal-mode"
    case statusListPreviewLineCount = "timeline.statuslines"
}

extension UserDefaults {
    func getValue<T: Decodable>(forKey key: GardensSettingsKey, default defaultValue: T) -> T {
        if let value = value(forKey: key) as? T {
            return value
        }
        return defaultValue
    }

    func value(forKey key: GardensSettingsKey) -> Any? {
        return value(forKey: key.rawValue)
    }

    func setValue(_ value: Any?, forKey key: GardensSettingsKey) {
        setValue(value, forKey: key.rawValue)
    }
}

// NOTE: Thanks to implementation from Swapnanil Dhol on their Medium article.
// https://swapnanildhol.medium.com/safer-and-cleaner-userdefaults-and-appstorage-23f22d989fcc
extension AppStorage {
    init(wrappedValue: Value, _ key: GardensSettingsKey, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: GardensSettingsKey, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: GardensSettingsKey, store: UserDefaults? = nil) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: GardensSettingsKey, store: UserDefaults? = nil) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: GardensSettingsKey, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: GardensSettingsKey, store: UserDefaults? = nil) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: GardensSettingsKey, store: UserDefaults? = nil) where Value == PostVisibility {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
