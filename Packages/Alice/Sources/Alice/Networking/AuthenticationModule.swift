//
//  Authentication.swift
//  Alice
//
//  Created by Marquis Kurt on 1/29/23.
//
//  This file is part of Alice.
//
//  Alice is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Alice comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Combine
import KeychainAccess
import SwiftUI

public class AuthenticationModule: ObservableObject {
    public struct RegisteredApplication {
        public let name: String
        public let website: String

        public init(name: String, website: String) {
            self.name = name
            self.website = website
        }

        public static let `default` = RegisteredApplication(
            name: "Starlight",
            website: "https://hyperspace.marquiskurt.net"
        )
    }

    /// An enum that allows us to know the state of the user authentication.
    public enum State: Equatable {
        case signedOut
        case refreshing, signinInProgress
        case authenthicated(authToken: String)
    }

    public static let shared = AuthenticationModule()

    public var canMakeAuthenticatedRequests: Bool {
        switch authState {
        case .authenthicated:
            return true
        default:
            return false
        }
    }

    /// An EnvironmentValue that allows us to open a URL using the appropriate system service.
    ///
    /// Can be used as follows:
    /// ```
    /// openURL(URL(string: "url")!)
    /// ```
    /// or
    /// ```
    /// openURL(url) // Where URL.type == URL
    /// ```
    @Environment(\.openURL) private var openURL

    /// The current state of the authorization (i.e. whether the user is signedOut, signing in, or already logged in).
    @Published public var authState = State.refreshing

    // Intializing Keychain
    public static let keychainService = "net.marquiskurt.starlight–secrets"

    private let scopes = ["read", "write", "follow", "push"]

    private let urlSuffix = "oauth"

    init() {
        _ = isOnMainThread(named: "OAUTH CLIENT STARTED")
        let keychain = Keychain(service: Alice.OAuth.keychainService)
        if let accessToken = keychain["starlight_acess_token"] {
            authState = .authenthicated(authToken: accessToken)
        } else {
            authState = .signedOut
        }
    }

    /// Returns the URL that needs to be opened in the browser to allow the user to complete registration.
    /// - Parameter instanceDomain: The domain in which the instance lies to start authorization for.
    /// - Parameter authHandler: An optional closure that runs once the URL is created to open. Defaults to
    ///     nil, using `openURL` instead.
    public func startOauthFlow(
        for instanceDomain: String,
        registeredAs app: RegisteredApplication = .default,
        authHandler: ((URL) -> Void)? = nil,
        onBadURL badURLHandler: ((String) -> Void)? = nil
    ) async {
        //  First, we initialize the keychain object
        let keychain = Keychain(service: Alice.OAuth.keychainService)

        // Check if the URL is valid, and return if the URL can't be created.
        if URL(string: "https://\(instanceDomain)") == nil {
            badURLHandler?(instanceDomain)
            return
        }

        //  Then, we assign the domain of the instance we are working with.
        keychain["starlight_instance_domain"] = instanceDomain
        Alice.instanceDomain = instanceDomain

        //  Now, we change the state of the oauth to .signInProgress
        DispatchQueue.main.async {
            self.authState = .signinInProgress
        }

        let response: Alice.Response<Application> = await Alice.shared.post(.apps, params: [
            "client_name": app.name,
            "redirect_uris": "\(Alice.shared.urlPrefix)://\(urlSuffix)",
            "scopes": scopes.joined(separator: " "),
            "website": app.website
        ])

        switch response {
        case .success(let client):
            keychain["starlight_client_id"] = client.clientId
            keychain["starlight_client_secret"] = client.clientSecret

            //  Then, we generate the url we need to visit for authorizing the user
            let url = Alice.apiURL.appendingPathComponent(Endpoint.authorizeUser.path)
                .queryItem("client_id", value: client.clientId)
                .queryItem("redirect_uri", value: "\(Alice.shared.urlPrefix)://\(urlSuffix)")
                .queryItem("scope", value: scopes.joined(separator: " "))
                .queryItem("response_type", value: "code")

            //  And finally, we open the url in the browser.
            if let handler = authHandler {
                handler(url)
            } else {
                openURL(url)
            }
        case .failure(let error):
            print("Failed to start OAuth flow: \(error.localizedDescription)")
        }
    }

    /// Continues with the OAuth flow after obtaining the user authorization code from the redirect URI
    public func continueOauthFlow(_ url: URL) async {
        if let code = url.queryParameters?.first(where: { $0.key == "code" }) {
            await continueOauthFlow(code.value)
        }
    }

    /// Continues with the OAuth flow after obtaining the user authorization code from the redirect URI
    public func continueOauthFlow(_ code: String) async {
        let keychain = Keychain(service: Alice.OAuth.keychainService)
        let response: Alice.Response<Token> = await Alice.shared.post(.token, params: [
            "client_id": keychain["starlight_client_id"]!,
            "client_secret": keychain["starlight_client_secret"]!,
            "redirect_uri": "\(Alice.shared.urlPrefix)://\(urlSuffix)",
            "grant_type": "authorization_code",
            "code": code,
            "scope": scopes.joined(separator: " ")
        ])

        switch response {
        case .success(let tokenData):
            keychain["starlight_acess_token"] = tokenData.accessToken
            DispatchQueue.main.async {
                self.authState = .authenthicated(authToken: tokenData.accessToken)
            }
        case .failure(let error):
            print("Failed to get access token: \(error.localizedDescription)")
        }
    }

    /// Removes the tokens in the keychain for this app, effectively signing a user out.
    public func signOut() async {
        let keychain = Keychain(service: Alice.OAuth.keychainService)

        let response: Alice.Response<EmptyNode> = await Alice.shared.post(.revokeToken, params: [
            "client_id": keychain["starlight_client_id"]!,
            "client_secret": keychain["starlight_client_secret"]!,
            "token": keychain["starlight_access_token"] ?? ""
        ])

        switch response {
        case .success:
            break
        case .failure(let error):
            print("Failed to revoke token: \(error)")
        }

        do {
            try keychain.removeAll()
            DispatchQueue.main.async {
                self.authState = .signedOut
            }
        } catch {
            print(error)
        }
    }
}
