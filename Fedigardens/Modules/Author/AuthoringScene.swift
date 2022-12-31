//
//  AuthoringScene.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/25/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Alice
import enum Alice.Visibility

struct AuthoringScene: Scene {
    @State var deeplinkedContext: AuthoringContext?

    var body: some Scene {
        WindowGroup("status.create", for: AuthoringContext.self) { authorContext in
            Group {
                if let context = authorContext.wrappedValue {
                    NavigationStack {
                        AuthorView(authoringContext: context)
                    }
                }
            }
        }
        .commands { TextEditingCommands() }

        WindowGroup("status.create") {
            Group {
                if let context = deeplinkedContext {
                    NavigationStack {
                        AuthorView(authoringContext: context)
                    }
                }
            }
            .handlesExternalEvents(preferring: ["create"], allowing: ["create"])
            .onOpenURL { url in
                getContextFromDeeplink(of: url)
            }
        }
        .handlesExternalEvents(
            matching: .init(arrayLiteral: "create")
        )
        .commands { TextEditingCommands() }
    }

    private func getContextFromDeeplink(of url: URL) {
        guard let params = url.queryParameters else { return }
        deeplinkedContext = AuthoringContext(
            replyingToID: params["replyID"] ?? "",
            forwardingURI: params["forwardURI"] ?? "",
            participants: params["participants"] ?? "",
            visibility: Visibility(rawValue: params["visibility"] ?? "public") ?? .public
        )
    }
}
