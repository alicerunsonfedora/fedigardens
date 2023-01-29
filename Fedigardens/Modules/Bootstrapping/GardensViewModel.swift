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

import Foundation
import Combine
import Alice
import EmojiText

class GardensViewModel: ObservableObject {
    @Published var userProfile: Account?
    @Published var interventionAuthorization: InterventionAuthorizationContext?
    @Published var emojis: [RemoteEmoji] = []

    func checkAuthorizationToken(from url: URL) {
        guard url.absoluteString.contains("gardens://oauth") else { return }
        Task {
            await Alice.OAuth.shared.continueOauthFlow(url)
        }
    }

    func createInterventionContext(from url: URL) -> InterventionAuthorizationContext? {
        guard let parameters = url.queryParameters else {
            interventionAuthorization = nil
            return nil
        }
        let allowedTimeInterval = TimeInterval(parameters["allowedTimeInterval"] ?? "0") ?? 0
        let allowedFetchSize = Int(parameters["allowedPostsCount"] ?? "10") ?? 10
        interventionAuthorization = .init(allowedTimeInterval: allowedTimeInterval, allowedFetchSize: allowedFetchSize)
        return interventionAuthorization
    }

    func getUserProfile() async {
        guard Alice.OAuth.shared.canMakeAuthenticatedRequests else { return }
        let response: Alice.Response<Account> = await Alice.shared.get(.verifyAccountCredentials)
        switch response {
        case .success(let profile):
            DispatchQueue.main.async {
                self.userProfile = profile
            }
        case .failure(let error):
            print("Failed to fetch user: \(error.localizedDescription)")
        }
    }

    func getInstanceEmojis() async {
        guard Alice.OAuth.shared.canMakeAuthenticatedRequests else { return }
        let response: Alice.Response<[Emoji]> = await Alice.shared.get(.customEmojis)
        switch response {
        case .success(let newEmojis):
            DispatchQueue.main.async {
                self.emojis = newEmojis.map { emoji in emoji.remote() }
            }
        case .failure(let error):
            print("Failed to fetch emojis: \(error.localizedDescription)")
        }
    }
}
