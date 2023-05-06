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

    public static let shared = AuthenticationModule(using: Keychain(service: Alice.OAuth.keychainService))

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

    init<T: AliceSecurityModule>(using secureModule: T) {
        _ = isOnMainThread(named: "OAUTH CLIENT STARTED")
        if let accessToken = secureModule.getSecureStore("starlight_acess_token") {
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
        using service: Alice = .shared,
        authHandler: ((URL) -> Void)? = nil,
        onBadURL badURLHandler: ((String) -> Void)? = nil
    ) async {
        await startOauthFlow(
            for: instanceDomain,
            registeredAs: app,
            using: service,
            store: Keychain(service: Alice.OAuth.keychainService),
            authHandler: authHandler,
            onBadURL: badURLHandler
        )
    }

    func startOauthFlow<T: AliceSecurityModule>(
        for instanceDomain: String,
        registeredAs app: RegisteredApplication = .default,
        using service: Alice = .shared,
        store: T,
        authHandler: ((URL) -> Void)? = nil,
        onBadURL badURLHandler: ((String) -> Void)? = nil
    ) async {
        // Check if the URL is valid, and return if the URL can't be created.
        if URL(string: "https://\(instanceDomain)") == nil {
            badURLHandler?(instanceDomain)
            return
        }

        //  Then, we assign the domain of the instance we are working with.
        store.setSecureStore(instanceDomain, forKey: "starlight_instance_domain")
        Alice.instanceDomain = instanceDomain

        //  Now, we change the state of the oauth to .signInProgress
        DispatchQueue.main.async {
            self.authState = .signinInProgress
        }

        let response: Alice.Response<Application> = await service.post(.apps, params: [
            "client_name": app.name,
            "redirect_uris": "\(Alice.shared.urlPrefix)://\(urlSuffix)",
            "scopes": scopes.joined(separator: " "),
            "website": app.website
        ])

        switch response {
        case .success(let client):
            store.setSecureStore(client.clientId, forKey: "starlight_client_id")
            store.setSecureStore(client.clientSecret, forKey: "starlight_client_secret")

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
    public func continueOauthFlow<T: AliceSecurityModule>(_ url: URL, store: T) async {
        if let code = url.queryParameters?.first(where: { $0.key == "code" }) {
            await continueOauthFlow(code.value, store: store)
        }
    }

    /// Continues with the OAuth flow after obtaining the user authorization code from the redirect URI
    public func continueOauthFlow(_ url: URL) async {
        await continueOauthFlow(url, store: Keychain(service: Alice.OAuth.keychainService))
    }

    func continueOauthFlow<T: AliceSecurityModule>(
        _ code: String,
        using service: Alice = .shared,
        store: T
    ) async {
        let response: Alice.Response<Token> = await service.post(.token, params: [
            "client_id": store.getSecureStore("starlight_client_id")!,
            "client_secret": store.getSecureStore("starlight_client_secret")!,
            "redirect_uri": "\(Alice.shared.urlPrefix)://\(urlSuffix)",
            "grant_type": "authorization_code",
            "code": code,
            "scope": scopes.joined(separator: " ")
        ])

        switch response {
        case .success(let tokenData):
            store.setSecureStore(tokenData.accessToken, forKey: "starlight_acess_token")
            DispatchQueue.main.async {
                self.authState = .authenthicated(authToken: tokenData.accessToken)
            }
        case .failure(let error):
            print("Failed to get access token: \(error.localizedDescription)")
        }
    }

    func signOut<T: AliceSecurityModule>(using service: Alice = .shared, store: T) async {
        let response: Alice.Response<EmptyNode> = await service.post(.revokeToken, params: [
            "client_id": store.getSecureStore("starlight_client_id")!,
            "client_secret": store.getSecureStore("starlight_client_secret")!,
            "token": store.getSecureStore("starlight_access_token") ?? ""
        ])

        switch response {
        case .success:
            break
        case .failure(let error):
            print("Failed to revoke token: \(error)")
        }

        store.flush()
        DispatchQueue.main.async {
            self.authState = .signedOut
        }
    }

    /// Removes the tokens in the keychain for this app, effectively signing a user out.
    public func signOut(using service: Alice = .shared) async {
        await signOut(using: service, store: Keychain(service: Alice.OAuth.keychainService))
    }
}
