//
//  GardensViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/3/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import struct Alice.CustomEmoji
import Combine
import EmojiText
import Foundation
import Interventions

class GardensViewModel: ObservableObject {
    @Published var currentInterventionAuthContext = InterventionAuthorizationContext.default
    @Published var overiddenFrugalMode: Bool = false
    @Published var userProfile: Account?
    @Published var emojis: [RemoteEmoji] = []

    func checkAuthorizationToken(from url: URL) async {
        guard url.absoluteString.contains("gardens://oauth") else { return }
        await Alice.OAuth.shared.continueOauthFlow(url)
    }

    func createInterventionContext(from url: URL) -> InterventionAuthorizationContext? {
        guard let parameters = url.queryParameters else { return nil }
        let allowedTimeInterval = TimeInterval(parameters["allowedTimeInterval"] ?? "0") ?? 0
        let allowedFetchSize = Int(parameters["allowedPostsCount"] ?? "10") ?? 10
        return InterventionAuthorizationContext(allowedTimeInterval: allowedTimeInterval,
                                                allowedFetchSize: allowedFetchSize)
    }

    @MainActor
    func updateInterventionContext<T: InterventionLinkOpener>(drivedFrom state: InterventionFlow<T>.State) async {
        if case .authorizedIntervention(_, let context) = state {
            currentInterventionAuthContext = context
            return
        }
        currentInterventionAuthContext = .default
    }

    @MainActor
    func updateInterventionContext(to newContext: InterventionAuthorizationContext) async {
        currentInterventionAuthContext = newContext
    }

    @MainActor
    func overrideFrugalMode(_ state: Bool) async {
        overiddenFrugalMode = state
    }

    func getUserProfile() async {
        guard Alice.OAuth.shared.canMakeAuthenticatedRequests else { return }
        let response: Alice.Response<Account> = await Alice.shared.get(.verifyAccountCredentials)
        switch response {
        case .success(let profile):
            await MainActor.run {
                self.userProfile = profile
            }
        case .failure(let error):
            print("Failed to fetch user: \(error.localizedDescription)")
        }
    }

    func getInstanceEmojis() async {
        guard Alice.OAuth.shared.canMakeAuthenticatedRequests else { return }
        let response: Alice.Response<[CustomEmoji]> = await Alice.shared.get(.customEmojis)
        switch response {
        case .success(let newEmojis):
            await MainActor.run {
                self.emojis = newEmojis.map(\.remoteEmoji)
            }
        case .failure(let error):
            print("Failed to fetch emojis: \(error.localizedDescription)")
        }
    }
}
