//
//  Shout.swift
//  Gardens
//
//  Created by Marquis Kurt on 25/1/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import SwiftUI

/// The main entry structure of the app.
@main
struct Shout: App {
    @State private var userProfile: Account?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.userProfile, userProfile ?? MockData.profile!)
                .onOpenURL { url in
                    checkAuthorizationToken(from: url)
                }
                .onAppear {
                    Chica.shared.setRequestPrefix(to: "gardens://")
                    Task {
                        await getUserProfile()
                    }
                }
        }

        WindowGroup(for: Status.self) { status in
            NavigationStack {
                StatusDetailView(status: status.wrappedValue!, level: .parent)
            }.handlesExternalEvents(preferring: ["statusdetail"], allowing: ["statusdetail"])
        }
        .handlesExternalEvents(
            matching: .init(arrayLiteral: "statusdetail")
        )

        AuthoringScene()
    }

    private func checkAuthorizationToken(from url: URL) {
        guard url.absoluteString.contains("gardens://oauth") else { return }
        Task {
            await Chica.OAuth.shared.continueOauthFlow(url)
        }
    }

    private func getUserProfile() async {
        if let acct: Account? = try? await Chica.shared.request(.get, for: .verifyAccountCredentials) {
            userProfile = acct
        }
    }
}
