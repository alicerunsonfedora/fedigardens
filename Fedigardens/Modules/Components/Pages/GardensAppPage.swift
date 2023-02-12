//
//  GardensAppPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

/// An enumeration representing the various pages in the app.
enum GardensAppPage: Hashable {
    case forYou
    case local
    case `public`
    case messages
    case selfPosts
    case saved
    case notifications
    case mentions
    case list(id: String)
    case trending(id: String)
    case settings
    case search

    var localizedTitle: LocalizedStringKey {
        switch self {
        case .forYou:
            return "endpoint.home"
        case .local:
            return "endpoint.local"
        case .public:
            return "endpoint.latest"
        case .messages:
            return "endpoint.directmessage"
        case .selfPosts:
            return "endpoint.selfposts"
        case .mentions:
            return "endpoint.mentions"
        case .notifications:
            return "endpoint.notifications"
        case .trending:
            return "endpoint.trending"
        case .list:
            return "endpoint.lists"
        case .saved:
            return "endpoint.saved"
        case .settings:
            return "general.settings"
        case .search:
            return "endpoint.search"
        }
    }

    var symbol: String {
        switch self {
        case .forYou:
            return "house"
        case .local:
            return "building.2"
        case .public:
            return "sparkles"
        case .messages:
            return "bubble.left.and.bubble.right"
        case .selfPosts:
            return "person.circle"
        case .saved:
            return "bookmark"
        case .notifications:
            return "bell"
        case .mentions:
            return "arrowshape.turn.up.left.2.circle"
        case .list:
            return "folder"
        case .trending:
            return "tag"
        case .settings:
            return "gear"
        case .search:
            return "magnifyingglass"
        }
    }
}

extension Label where Title == Text, Icon == Image {
    init(page: GardensAppPage) {
        self = Label(page.localizedTitle, systemImage: page.symbol)
    }
}
