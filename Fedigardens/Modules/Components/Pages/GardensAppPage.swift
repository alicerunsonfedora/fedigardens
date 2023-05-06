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

extension GardensAppPage: RawRepresentable {
    var rawValue: String {
        switch self {
        case .forYou:
            return "gardens.page.foryou"
        case .local:
            return "gardens.page.local"
        case .public:
            return "gardens.page.public"
        case .messages:
            return "gardens.page.messages"
        case .selfPosts:
            return "gardens.page.authored"
        case .saved:
            return "gardens.page.saved"
        case .notifications:
            return "gardens.page.notifications"
        case .mentions:
            return "gardens.page.mentions"
        case .list(let id):
            return "gardens.page.list:\(id)"
        case .trending(let id):
            return "gardens.page.trends:\(id)"
        case .settings:
            return "gardens.page.settings"
        case .search:
            return "gardens.page.search"
        }
    }

    init?(rawValue: String) { // swiftlint:disable:this cyclomatic_complexity
        switch rawValue {
        case "gardens.page.foryou":
            self = .forYou
        case "gardens.page.local":
            self = .local
        case "gardens.page.public":
            self = .public
        case "gardens.page.messages":
            self = .messages
        case "gardens.page.authored":
            self = .selfPosts
        case "gardens.page.saved":
            self = .saved
        case "gardens.page.notifications":
            self = .notifications
        case "gardens.page.mentions":
            self = .mentions
        case "gardens.page.settings":
            self = .settings
        case "gardens.page.search":
            self = .search
        case rawValue where rawValue.starts(with: "gardens.page.list:"):
            guard let id = rawValue.split(separator: ":").last else { return nil }
            self = .list(id: String(id))
        case rawValue where rawValue.starts(with: "gardens.page.trends:"):
            guard let id = rawValue.split(separator: ":").last else { return nil }
            self = .trending(id: String(id))
        default:
            return nil
        }
    }
}

extension Label where Title == Text, Icon == Image {
    init(page: GardensAppPage) {
        self = Label(page.localizedTitle, systemImage: page.symbol)
    }
}
