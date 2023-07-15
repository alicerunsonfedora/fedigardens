//
//  GardensSettingsKey.swift
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

/// An enumeration for the various settings that Fedigardens contains.
///
/// These keys are used to access values more directly in both UserDefaults and AppStorage.
public enum GardensSettingsKey: String {
    /// The number of items to fetch at a given time.
    case loadLimit = "network.load-limit"

    /// Whether to show statistics for the number of favorites and boosts on a discussion.
    case showsStatistics = "status.shows-statistics"

    /// Whether to separate discussions into authored versus boosted content.
    case useFocusedInbox = "timeline.original-filter"

    /// Whether to always show the user handle on discussions.
    case alwaysShowUserHandle = "timeline.show-handles"

    /// Whether the interventions feature is enabled.
    case allowsInterventions = "health.interventions"

    /// Whether interventions will occur when attempting to refresh content.
    case intervenesOnRefresh = "health.interventions.refresh"

    /// Whether interventions will occur when attempting to fetch more content.
    case intervenesOnFetch = "health.interventions.fetch"

    /// The maximum number of characters a discussion can have.
    ///
    /// Mastodon usually enforces a 500 character limit, but other instances may have this value lowered or raised.
    case characterLimit = "author.characterlimit"

    /// Whether the character limit should be enforced when writing a discussion.
    case enforceCharacterLimit = "author.enforcelimit"

    /// The default visibility when authoring a new discussion.
    case defaultVisibility = "author.defaultvisibility"

    /// The default visibility when replying to a discussion.
    case defaultReplyVisibility = "author.replyvisibility"

    /// The default visibility when creating a quote discussion.
    case defaultQuoteVisibility = "author.quotevisibility"

    /// The default visibility when auhtoring feedback to the Fedigardens account.
    case defaultFeedbackVisibility = "author.feedbackvisibility"

    /// Whether the author of a quoted discussion should be added as a participant to the discussion.
    case addQuoteParticipant = "author.quoteparticipant"

    /// Whether to actively redirect messaging to a Matrix room, if one has been identified in a person's profile.
    case preferMatrixConversations = "profiles.prefermatrix"

    /// Whether frugal mode is enabled.
    case frugalMode = "core.frugal-mode"

    /// The number of lines to display for a discussion when it appears in a timeline list.
    case statusListPreviewLineCount = "timeline.statuslines"
}
