//
//  Shout.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 25/1/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import SwiftUI

/// The main entry structure of the app.
@main
struct Shout: App {
    @StateObject private var globalStore = GardensViewModel()
    @StateObject private var interventionHandler = InterventionHandler()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.userProfile, globalStore.userProfile ?? MockData.profile!)
                .environment(\.interventionAuthorization, globalStore.interventionAuthorization ?? .default)
                .environmentObject(interventionHandler)
                .environment(\.customEmojis, globalStore.emojis)
                .environment(\.enforcedFrugalMode, globalStore.overrideFrugalMode)
                .onOpenURL { url in
                    globalStore.checkAuthorizationToken(from: url)
                    if let newContext = globalStore.createInterventionContext(from: url) {
                        interventionHandler.assignNewContext(newContext)
                    }
                }
                .onAppear {
                    Alice.shared.setRequestPrefix(to: "gardens://")
                    Task {
                        await globalStore.getUserProfile()
                        await globalStore.getInstanceEmojis()
                    }
                }
                .onReceive(of: Notification.Name.NSProcessInfoPowerStateDidChange) { _ in
                    globalStore.overrideFrugalModeFromLowPowerMode()
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
}
