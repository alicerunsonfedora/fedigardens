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

import Alice
import Foundation
import GardenSettings

extension UserDefaults {
    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var loadLimit: Int {
        get { max(10, getValue(forKey: .loadLimit, default: 10)) }
        set { setValue(newValue, forKey: .loadLimit) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var frugalMode: Bool {
        get { getValue(forKey: .frugalMode, default: false) }
        set { setValue(newValue, forKey: .frugalMode) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var showsStatistics: Bool {
        get { getValue(forKey: .showsStatistics, default: false) }
        set { setValue(newValue, forKey: .showsStatistics) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var alwaysShowUserHandle: Bool {
        get { getValue(forKey: .alwaysShowUserHandle, default: true) }
        set { setValue(newValue, forKey: .alwaysShowUserHandle) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var showOriginalPostsOnly: Bool {
        get { getValue(forKey: .useFocusedInbox, default: false) }
        set { setValue(newValue, forKey: .useFocusedInbox) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var preferMatrixConversations: Bool {
        get { getValue(forKey: .preferMatrixConversations, default: true) }
        set { setValue(newValue, forKey: .preferMatrixConversations) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var statusListPreviewLineCount: Int {
        get { getValue(forKey: .statusListPreviewLineCount, default: 2) }
        set { setValue(newValue, forKey: .statusListPreviewLineCount) }
    }

    // MARK: - Intervention Settings
    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var allowsInterventions: Bool {
        get { getValue(forKey: .allowsInterventions, default: true) }
        set { setValue(newValue, forKey: .allowsInterventions) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var intervenesOnRefresh: Bool {
        get { getValue(forKey: .intervenesOnRefresh, default: true) }
        set { setValue(newValue, forKey: .intervenesOnRefresh) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var intervenesOnFetch: Bool {
        get { getValue(forKey: .intervenesOnFetch, default: true) }
        set { setValue(newValue, forKey: .intervenesOnFetch) }
    }

    // MARK: - Composer Settings
    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var characterLimit: Int {
        get { getValue(forKey: .characterLimit, default: 500) }
        set { setValue(newValue, forKey: .characterLimit) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var enforceCharacterLimit: Bool {
        get { getValue(forKey: .enforceCharacterLimit, default: true) }
        set { setValue(newValue, forKey: .enforceCharacterLimit) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var addQuoteParticipant: Bool {
        get { getValue(forKey: .addQuoteParticipant, default: true) }
        set { setValue(newValue, forKey: .addQuoteParticipant) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var defaultVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultVisibility, default: "public")
            return PostVisibility(rawValue: reflectedValue) ?? .public
        }
        set { setValue(newValue.rawValue, forKey: .defaultVisibility) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var defaultReplyVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultReplyVisibility, default: "unlisted")
            return PostVisibility(rawValue: reflectedValue) ?? .unlisted
        }
        set { setValue(newValue.rawValue, forKey: .defaultReplyVisibility) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var defaultQuoteVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultQuoteVisibility, default: "public")
            return PostVisibility(rawValue: reflectedValue) ?? .public
        }
        set { setValue(newValue.rawValue, forKey: .defaultQuoteVisibility) }
    }

    @available(*, deprecated, message: "Use the @GardenSetting property wrapper from the GardenSettings module.")
    var defaultFeedbackVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultFeedbackVisibility, default: "direct")
            return PostVisibility(rawValue: reflectedValue) ?? .direct
        }
        set { setValue(newValue.rawValue, forKey: .defaultFeedbackVisibility) }
    }
}
