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

import Alice
import enum Alice.Visibility
import SwiftUI

struct AuthoringScene: Scene {
    @State var deeplinkedContext: AuthoringContext?

    var body: some Scene {
        WindowGroup("status.create", for: AuthoringContext.self) { authorContext in
            Group {
                NavigationStack {
                    AuthorView(authoringContext: authorContext.wrappedValue ?? AuthoringContext())
                }
            }
        }
        .commands { TextEditingCommands() }

        WindowGroup("status.create") {
            Group {
                NavigationStack {
                    AuthorView(authoringContext: deeplinkedContext ?? AuthoringContext())
                }
            }
            .handlesExternalEvents(
                preferring: ["create", "app.fedigardens.mail.authorscene"],
                allowing: ["create", "app.fedigardens.mail.authorscene"]
            )
            .onOpenURL { url in
                getContextFromDeeplink(of: url)
            }
        }
        .handlesExternalEvents(
            matching: ["create", "app.fedigardens.mail.authorscene"]
        )
        .commands { TextEditingCommands() }
    }

    private func getContextFromDeeplink(of url: URL) {
        deeplinkedContext = AuthoringContext(from: url)
    }
}
