//
//  AuthenticationViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/29/22.
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

class AuthenticationViewModel: ObservableObject {
    typealias AuthenticationModule = Alice.OAuth
    typealias RegisteredApp = AuthenticationModule.RegisteredApplication
    @Published var authenticationDomainName = ""
    @Published var authenticationAuthorizedURL: URL?
    @Published var displayAuthenticationDialog = false
    @Published var authenticationDomainRejected = false

    var authenticationState: AuthenticationModule.State {
        return authModule.authState
    }

    var authenticationRejectionTitle: String {
        String(
            format: NSLocalizedString("auth.disallowed.title", comment: "Disallowed domain"),
            authenticationDomainName
        )
    }

    private var authModule: AuthenticationModule = .shared
    private var disallowedDomains = Set<String>()
    private let app = RegisteredApp(name: "Fedigardens", website: "https://fedigardens.app")

    init(with authModule: Alice.OAuth) {
        self.authModule = authModule
        self.retrieveDisallowList()
    }

    init() {
        self.retrieveDisallowList()
    }

    func startAuthenticationWorkflow() async {
        guard !disallowedDomains.contains(authenticationDomainName) else {
            DispatchQueue.main.async { self.authenticationDomainRejected.toggle() }
            return
        }
        await authModule.startOauthFlow(for: authenticationDomainName, registeredAs: app) { url in
            DispatchQueue.main.async {
                self.authenticationAuthorizedURL = url
                self.displayAuthenticationDialog.toggle()
            }
        }
    }

    private func retrieveDisallowList() {
        guard let disallowPath = Bundle.main.path(forResource: "Disallow", ofType: "plist") else { return }
        let url = URL(filePath: disallowPath)
        do {
            let data = try Data(contentsOf: url)
            let decoded = try PropertyListDecoder().decode([String].self, from: data)
            disallowedDomains = Set(decoded)
        } catch {
            print("Fetch disallow list error: \(error.localizedDescription)")
        }
    }
}
