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
import FrugalMode
import Interventions
import SwiftUI
import UIKit

/// The main entry structure of the app.
@main
struct Shout: App {
    @State private var frugalFlow = FrugalModeFlow()
    @State private var interventions = InterventionFlow(linkOpener: UIApplication.shared)
    @StateObject private var globalStore = GardensViewModel()

    private var overrideFrugalMode: Bool {
        frugalFlow.state == .overridden
    }

    private var currentInterventionAuthContext: InterventionAuthorizationContext {
        if case .authorizedIntervention(_, let context) = interventions.state {
            return context
        }
        return .default
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.userProfile, globalStore.userProfile ?? MockData.profile!)
                .environment(\.interventionAuthorization, currentInterventionAuthContext)
                .environmentObject(interventions)
                .environment(\.customEmojis, globalStore.emojis)
                .environment(\.enforcedFrugalMode, overrideFrugalMode)
                .onOpenURL { url in
                    globalStore.checkAuthorizationToken(from: url)
                    if let newContext = globalStore.createInterventionContext(from: url),
                       case .requestedIntervention = interventions.state {
                        Task {
                            await interventions.emit(.authorizeIntervention(.now, context: newContext))
                        }
                    }
                }
                .onAppear {
                    interventions = .init(linkOpener: UIApplication.shared)
                    Alice.shared.setRequestPrefix(to: "gardens")
                    Task {
                        await withTaskGroup(of: Void.self) { group in
                            group.addTask { await frugalFlow.emit(.checkOverrides) }
                            group.addTask { await globalStore.getUserProfile() }
                            group.addTask { await globalStore.getInstanceEmojis() }
                        }
                    }
                }
                .onReceive(of: Notification.Name.NSProcessInfoPowerStateDidChange) { _ in
                    Task {
                        await frugalFlow.emit(.checkOverrides)
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
}
