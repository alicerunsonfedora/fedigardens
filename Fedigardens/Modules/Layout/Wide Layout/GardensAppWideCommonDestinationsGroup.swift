//
//  GardensAppWideCommonDestinationsGroup.swift
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

import SwiftUI

struct GardensAppWideCommonDestinationsGroup: View {
    var body: some View {
        Group {
            GardensPageLink(page: .forYou)
                .keyboardShortcut("h", modifiers: [.command, .shift])
            GardensPageLink(page: .local)
                .keyboardShortcut("l", modifiers: [.command, .shift])
            GardensPageLink(page: .mentions)
                .keyboardShortcut("i", modifiers: [.command, .shift])
            GardensPageLink(page: .search)
                .keyboardShortcut(.space, modifiers: [.command, .shift])
            GardensPageLink(page: .settings)
                .keyboardShortcut(",", modifiers: .command)

            Section {
                GardensPageLink(page: .public)
                GardensPageLink(page: .messages)
                GardensPageLink(page: .selfPosts)
                GardensPageLink(page: .saved)
            } header: {
                Text("general.more")
            }
        }
    }
}
