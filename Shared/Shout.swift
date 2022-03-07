//
//  Shout.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 25/1/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import SwiftUI

/// The main entry structure of the app.
@main
struct Shout: App {
    @Environment(\.openURL) var openURL

    /// The ID of the status that the user will reply to in the author view.
    ///
    /// This is used internally to set up the state of ``AuthorView`` when the user clicks on a "link" that opens a URL
    /// corresponding to a reply action, such as `shout://create?reply_id=XXX` where `XXX` is the ID of the status
    /// to reply to. This is typically used for macOS specifically.
    @State private var replyID: String = ""

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Chica.handleURL(url: url, actions: [:])
                }
                .onAppear {
                    // Set the app's URL prefix to match our URL scheme. This should prevent Codename Shout from
                    // intercepting URLs designed to go to Hyperspace Starlight.
                    Chica.shared.setRequestPrefix(to: "shout://")
                }
        }
#if os(macOS)
            .commands {
                CommandGroup(after: .appSettings) {
                    BetaYouTrackSubmitButton(presentationMode: .menuItem)
                }
            }
#endif

        WindowGroup("general.status", id: "create") {
            authorView
                .handlesExternalEvents(preferring: ["create"], allowing: ["create"])
        }
        .handlesExternalEvents(
            matching: .init(arrayLiteral: "create")
        )
        .commands { TextEditingCommands() }

#if os(macOS)
        Settings {
            SettingsView()
                .frame(maxWidth: 550, minHeight: 250)
        }
#endif
    }

    private var authorView: some View {
        Group {
#if os(macOS)
            AuthorView(promptId: $replyID)
                .frame(minWidth: 500, idealWidth: 550, minHeight: 250, idealHeight: 300)
#else
            NavigationView {
                AuthorView(promptId: $replyID)
            }
            .navigationViewStyle(.stack)
#endif
        }
        .onOpenURL { url in
            if let params = url.queryParameters {
                replyID = params["reply_id"] ?? ""
            }
        }
        .onDisappear {
            replyID = ""
        }
    }
}
