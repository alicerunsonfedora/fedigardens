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
import Chica

class AuthenticationViewModel: ObservableObject {
    typealias AuthenticationModule = Chica.OAuth
    typealias RegisteredApp = AuthenticationModule.RegisteredApplication
    @Published var authenticationDomainName = ""
    @Published var authenticationAuthorizedURL: URL?
    @Published var displayAuthenticationDialog = false

    var authenticationState: AuthenticationModule.State {
        return authentication.authState
    }

    private var authentication: AuthenticationModule = .shared
    private let app = RegisteredApp(name: "Fedigardens", website: "https://github.com/alicerunsonfedora/fedigardens")

    init(with authModule: Chica.OAuth) {
        self.authentication = authModule
    }

    init() {}

    func startAuthenticationWorkflow() async {
        await authentication.startOauthFlow(for: authenticationDomainName, registeredAs: app) { url in
            DispatchQueue.main.async {
                self.authenticationAuthorizedURL = url
                self.displayAuthenticationDialog.toggle()
            }
        }
    }
}
