//
//  AuthenticationModule.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/16/23.
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
import TootSDK
import KeychainAccess

class AuthenticationModule: ObservableObject {
    enum State: Hashable {
        case initial
        case unauthenticated
        case authenticated(token: String)
    }

    @Published var authenticationState = State.initial

    private var keychain: Keychain
    private var instanceDomain: String? {
        didSet {
            self.keychain["starlight_instance_domain"] = instanceDomain
        }
    }

    init() {
        self.keychain = Keychain(service: "net.marquiskurt.starlight–secrets")
        self.instanceDomain = self.keychain["starlight_instance_domain"]
        self.authenticationState = .initial

        if let token = self.keychain["starlight_access_token"] {
            authenticationState = .authenticated(token: token)
        } else {
            authenticationState = .unauthenticated
        }
    }

    func client() async -> TootClient? {
        guard let instanceURL = URL(string: "https://\(instanceDomain ?? "mastodon.online")") else { return nil }
        switch authenticationState {
        case .authenticated(let token):
            return try? await TootClient(connect: instanceURL, clientName: "Fedigardens", accessToken: token)
        default:
            return try? await TootClient(connect: instanceURL, clientName: "Fedigardens")
        }
    }

    func startAuthenticationWorkflow(for domain: String) async {
        self.instanceDomain = domain
        guard authenticationState == .unauthenticated, let authClient = await client() else { return }
        guard let token = try? await authClient.presentSignIn(callbackURI: "gardens://oauth") else {
            print("Failed to present sign in window.")
            return
        }
        self.authenticationState = .authenticated(token: token)
        self.keychain["starlight_access_token"] = token
    }

    func synchronizeAuthenticationStatus() {
        if let token = self.keychain["starlight_access_token"] {
            authenticationState = .authenticated(token: token)
        } else {
            authenticationState = .unauthenticated
        }
    }
}
