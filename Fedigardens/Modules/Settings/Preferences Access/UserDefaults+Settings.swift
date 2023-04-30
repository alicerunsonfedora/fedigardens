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
import Alice

extension UserDefaults {
    var loadLimit: Int {
        get { max(10, getValue(forKey: .loadLimit, default: 10)) }
        set { setValue(newValue, forKey: .loadLimit) }
    }

    var frugalMode: Bool {
        get { getValue(forKey: .frugalMode, default: false) }
        set { setValue(newValue, forKey: .frugalMode) }
    }

    var showsStatistics: Bool {
        get { getValue(forKey: .showsStatistics, default: false) }
        set { setValue(newValue, forKey: .showsStatistics) }
    }

    var alwaysShowUserHandle: Bool {
        get { getValue(forKey: .alwaysShowUserHandle, default: true) }
        set { setValue(newValue, forKey: .alwaysShowUserHandle) }
    }

    var showOriginalPostsOnly: Bool {
        get { getValue(forKey: .useFocusedInbox, default: false) }
        set { setValue(newValue, forKey: .useFocusedInbox) }
    }

    var preferMatrixConversations: Bool {
        get { getValue(forKey: .preferMatrixConversations, default: true) }
        set { setValue(newValue, forKey: .preferMatrixConversations) }
    }

    // MARK: - Intervention Settings
    var allowsInterventions: Bool {
        get { getValue(forKey: .allowsInterventions, default: true) }
        set { setValue(newValue, forKey: .allowsInterventions) }
    }

    var intervenesOnRefresh: Bool {
        get { getValue(forKey: .intervenesOnRefresh, default: true) }
        set { setValue(newValue, forKey: .intervenesOnRefresh) }
    }

    var intervenesOnFetch: Bool {
        get { getValue(forKey: .intervenesOnFetch, default: true) }
        set { setValue(newValue, forKey: .intervenesOnFetch) }
    }

    // MARK: - Composer Settings
    var characterLimit: Int {
        get { getValue(forKey: .characterLimit, default: 500) }
        set { setValue(newValue, forKey: .characterLimit) }
    }

    var enforceCharacterLimit: Bool {
        get { getValue(forKey: .enforceCharacterLimit, default: true) }
        set { setValue(newValue, forKey: .enforceCharacterLimit) }
    }

    var addQuoteParticipant: Bool {
        get { getValue(forKey: .addQuoteParticipant, default: true) }
        set { setValue(newValue, forKey: .addQuoteParticipant) }
    }

    var defaultVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultVisibility, default: "public")
            return PostVisibility(rawValue: reflectedValue) ?? .public
        }
        set { setValue(newValue.rawValue, forKey: .defaultVisibility) }
    }

    var defaultReplyVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultReplyVisibility, default: "unlisted")
            return PostVisibility(rawValue: reflectedValue) ?? .unlisted
        }
        set { setValue(newValue.rawValue, forKey: .defaultReplyVisibility) }
    }

    var defaultQuoteVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultQuoteVisibility, default: "public")
            return PostVisibility(rawValue: reflectedValue) ?? .public
        }
        set { setValue(newValue.rawValue, forKey: .defaultQuoteVisibility) }
    }

    var defaultFeedbackVisibility: PostVisibility {
        get {
            let reflectedValue = getValue(forKey: .defaultFeedbackVisibility, default: "direct")
            return PostVisibility(rawValue: reflectedValue) ?? .direct
        }
        set { setValue(newValue.rawValue, forKey: .defaultFeedbackVisibility) }
    }
}
