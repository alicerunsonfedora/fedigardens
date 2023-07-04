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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.userProfile, globalStore.userProfile ?? MockData.profile!)
                .environment(\.interventionAuthorization, globalStore.currentInterventionAuthContext)
                .environment(\.customEmojis, globalStore.emojis)
                .environment(\.enforcedFrugalMode, globalStore.overiddenFrugalMode)
                .environmentObject(interventions)
                .onOpenURL { url in
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask { await globalStore.checkAuthorizationToken(from: url) }
                        group.addTask { await checkForInterventionsToAuthorize(url: url) }
                    }
                }
                .task {
                    await MainActor.run {
                        Alice.shared.setRequestPrefix(to: "gardens")
                        interventions = .init(linkOpener: UIApplication.shared)
                    }
                    await setupFlowSubscriptions()
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask { await frugalFlow.emit(.checkOverrides) }
                        group.addTask { await globalStore.getUserProfile() }
                        group.addTask { await globalStore.getInstanceEmojis() }
                    }
                }
                .onReceive(of: Notification.Name.NSProcessInfoPowerStateDidChange) { _ in
                    Task { await frugalFlow.emit(.checkOverrides) }
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

    @discardableResult
    func checkForInterventionsToAuthorize(url: URL) async -> Bool {
        guard let newContext = globalStore.createInterventionContext(from: url) else { return false }
        if case .requestedIntervention = await interventions.state {
            await interventions.emit(.authorizeIntervention(.now, context: newContext))
            return true
        }
        return false
    }

    private func setupFlowSubscriptions() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await frugalFlow.subscribe { state in
                    await globalStore.overrideFrugalMode(state == .overridden)
                }
            }
            group.addTask {
                await interventions.subscribe { state in
                    await globalStore.updateInterventionContext(drivedFrom: state)
                }
            }
        }
    }
}
