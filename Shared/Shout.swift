//
//  Shout.swift
//  Shared
//
//  Created by Marquis Kurt on 25/1/22.
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Chica

@main
struct Shout: App {

    @Environment(\.openURL) var openURL
    @State private var replyID: String = ""

    var body: some Scene {
        WindowGroup {
            ContentView()
                .handlesExternalEvents(preferring: ["home", "oauth"], allowing: ["home", "oauth"])
            .onOpenURL { url in
                print("You called me. URL: \(url.absoluteString)")
                Chica.handleURL(url: url, actions: [:])
            }
        }
        .handlesExternalEvents(matching: ["home", "oauth"])

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
