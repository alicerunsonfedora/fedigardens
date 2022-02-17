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
                .handlesExternalEvents(preferring: .init(arrayLiteral: "oauth"), allowing: .init(arrayLiteral: "oauth"))
                .onOpenURL { url in
                    Chica.handleURL(url: url, actions: [:])
                }
        }
        .handlesExternalEvents(matching: .init(arrayLiteral: "oauth"))

        #if os(macOS)
        WindowGroup("general.post") {
            AuthorView(promptId: $replyID)
                .frame(minWidth: 500, idealWidth: 550, minHeight: 250, idealHeight: 300)
                .onOpenURL { url in
                    if let params = url.queryParameters {
                        replyID = params["reply_id"] ?? ""
                    }
                }
                .onDisappear {
                    replyID = ""
                }
        }
        .handlesExternalEvents(matching: .init(arrayLiteral: "create"))
        .commands {
            TextEditingCommands()
        }
        #endif
    }
}
