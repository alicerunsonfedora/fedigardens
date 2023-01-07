/*
*   THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THIS
*   NON-VIOLENT PUBLIC LICENSE v4 ("LICENSE"). THE WORK IS PROTECTED BY
*   COPYRIGHT AND ALL OTHER APPLICABLE LAWS. ANY USE OF THE WORK OTHER THAN
*   AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS PROHIBITED. BY
*   EXERCISING ANY RIGHTS TO THE WORK PROVIDED IN THIS LICENSE, YOU AGREE
*   TO BE BOUND BY THE TERMS OF THIS LICENSE. TO THE EXTENT THIS LICENSE
*   MAY BE CONSIDERED TO BE A CONTRACT, THE LICENSOR GRANTS YOU THE RIGHTS
*   CONTAINED HERE IN AS CONSIDERATION FOR ACCEPTING THE TERMS AND
*   CONDITIONS OF THIS LICENSE AND FOR AGREEING TO BE BOUND BY THE TERMS
*   AND CONDITIONS OF THIS LICENSE.
*
*   This source file is part of the Codename Starlight open source project
*   This file was created by Alejandro Modroño Vara on 14/7/21.
*
*   See `LICENSE.txt` for license information
*   See `CONTRIBUTORS.txt` for project authors
*
*/
import Foundation
import KeychainAccess
import SwiftUI
import Combine

/**
The primary client object that handles all fediverse requests. It basically works as the logic controller of
 all the networking done by the app.

All of the getter and setter methods work asynchronously thanks to the new concurrency model introduced in
 Swift 5.5. They have been written to provide helpful error messages and have a state that can be traced by
 the app. This model works best in scenarios where data needs to be loaded into a view.

- Version 2.0

*/
public class Alice: ObservableObject, CustomStringConvertible {

    //  MARK: - OAuth
    /**
    An ObservableObject that handles everything related with user authentication. It can be acessed through the singleton `Chica.OAuth.shared()`.

    - Version 1.0

    */
    public class OAuth: ObservableObject {

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

        static public let shared = OAuth()

        /// An EnvironmentValue that allows us to open a URL using the appropriate system service.
        ///
        /// Can be used as follows:
        /// ```
        /// openURL(URL(string: "url")!)
        /// ```
        /// or
        ///```
        /// openURL(url) // Where URL.type == URL
        /// ```
        @Environment(\.openURL) private var openURL
        
        /// The current state of the authorization (i.e. whether the user is signedOut, signing in, or already logged in).
        @Published public var authState = State.refreshing

        //  MARK: – STORED PROPERTIES

        // Intializing Keychain
        static public let keychainService = "net.marquiskurt.starlight–secrets"

        private let scopes = ["read", "write", "follow", "push"]

        private let URL_SUFFIX = "oauth"

        init() {

            _ = isOnMainThread(named: "OAUTH CLIENT STARTED")

//            //  First, we are trying to see if there is a Tokens.plist file that we will use for our application.
//            if let path = Bundle.path(forResource: "Tokens", ofType: "plist", inDirectory: "Tokens"),
//               let secrets = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
//                self.secrets = secrets
//            } else {
//                self.secrets = nil
//                print("Error: We no secrets were found which means that you won't be able to use Starlight.")
//            }

            //  Now, we check whether the user is signed in or not.
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
            authHandler: ((URL) -> Void)? = nil
        ) async {

            //  First, we initialize the keychain object
            let keychain = Keychain(service: Alice.OAuth.keychainService)

            //  Then, we assign the domain of the instance we are working with.
            keychain["starlight_instance_domain"] = instanceDomain
            Alice.INSTANCE_DOMAIN = instanceDomain

            //  Now, we change the state of the oauth to .signInProgress
            DispatchQueue.main.async {
                self.authState = .signinInProgress
            }

            let response: Alice.Response<Application> = await Alice.shared.request(.post, for: .apps, params: [
                "client_name": app.name,
                "redirect_uris": "\(Alice.shared.urlPrefix)://\(URL_SUFFIX)",
                "scopes": scopes.joined(separator: " "),
                "website": app.website
            ])

            switch response {
            case .success(let client):
                keychain["starlight_client_id"] = client.clientId
                keychain["starlight_client_secret"] = client.clientSecret

                //  Then, we generate the url we need to visit for authorizing the user
                let url = Alice.API_URL.appendingPathComponent(Endpoint.authorizeUser.path)
                    .queryItem("client_id", value: client.clientId)
                    .queryItem("redirect_uri", value: "\(Alice.shared.urlPrefix)://\(URL_SUFFIX)")
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
            let response: Response<Token> = await Alice.shared.request(.post, for: .token, params: [
                "client_id": keychain["starlight_client_id"]!,
                "client_secret": keychain["starlight_client_secret"]!,
                "redirect_uri": "\(Alice.shared.urlPrefix)://\(URL_SUFFIX)",
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

            let response: Alice.Response<EmptyNode> = await Alice.shared.request(.post, for: .revokeToken, params: [
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

    //  MARK: - HTTPS METHODS
    public enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }

    public typealias Response<T: Decodable> = Result<T, FetchError>

    //  MARK: - PROPERTIES

    /// A singleton everybody can access to.
    static public let shared = Alice()

    //  MARK: – URLs

    /// The url prefix
    static private let DEFAULT_URL_PREFIX = "starlight"

    /// The domain (without the prefixes) of the instance.
    static var INSTANCE_DOMAIN: String = Keychain(service: OAuth.keychainService)["starlight_instance_domain"] ?? "mastodon.online"

    static public var API_URL: URL {
        return URL(string: "https://\(INSTANCE_DOMAIN)")!
    }

    /// Allows us to decode top-level values of the given type from the given JSON representation.
    private let decoder: JSONDecoder

    private var session: URLSession

    public var urlPrefix: String

    private var oauthStateCancellable: AnyCancellable?

    //  MARK: - INITIALIZERS

    public init() {

        _ = isOnMainThread(named: "CLIENT STARTED")
        urlPrefix = Alice.DEFAULT_URL_PREFIX

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        self.decoder = decoder
        var token: String? = nil

        //  For the moment, we still need to use Combine and Publishers a bit, but this might change over time.
        oauthStateCancellable = OAuth.shared.$authState.sink { state in
            switch state {
            case .authenthicated(let oToken):
                token = oToken
            default:
                break
            }
        }

        let configuration = URLSessionConfiguration.default
        var headers = ["User-Agent": "ChicaApp:v1.0 (by Starlight Development Team)."]
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        configuration.httpAdditionalHeaders = headers
        configuration.urlCache = .shared
        configuration.requestCachePolicy = .reloadRevalidatingCacheData
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120

        self.session = URLSession(configuration: configuration)

    }

    /// Sets the URL prefix of the Chica client when making requests.
    /// - Parameter urlPrefix: The URL prefix to use with this client.
    ///
    /// When the Chica class is first instantiated, the default URL prefix used is `starlight://`. When this method is
    /// called, any future requests made with ``request(_:for:params:)`` will use the new URL prefix.
    ///
    /// - Important: The URL prefix that is assigned to Chica should be a valid URL prefix type registered with your
    ///     app in Xcode or in the app's Info.plist.
    public func setRequestPrefix(to urlPrefix: String) {
        self.urlPrefix = urlPrefix
    }

    /// Resets the URL prefix of the Chica client to the default URL prefix.
    ///
    /// When calling this method, future requests will use the default URL prefix of `starlight://`.
    public func resetRequestPrefix() {
        self.urlPrefix = Alice.DEFAULT_URL_PREFIX
    }

    /// Returns a URLRequest with the specified URL, http method, and query parameters.
    static private func makeRequest(_ method: Method, url: URL, params: [String: String]? = nil) -> URLRequest {
        var request: URLRequest
        var url = url

        if let params = params {
            for (_, value) in params.enumerated() {
                url = url.queryItem(value.key, value: value.value)
            }
        }

        request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        let authState = Alice.OAuth.shared.authState
        if case .authenthicated(let token) = authState {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request

    }

    public func request<T: Decodable>(
        _ method: Method,
        for endpoint: Endpoint,
        params: [String: String]? = nil
    ) async -> Response<T> {
        let url = Self.API_URL.appendingPathComponent(endpoint.path)
        do {
            let (data, response) = try await self.session.data(for: Self.makeRequest(method, url: url, params: params))
            guard let response = response as? HTTPURLResponse else {
                return .failure(.unknownResponseError(response: response))
            }

            guard (200..<300).contains(response.statusCode) else {
                return .failure(
                    .message(
                        reason: "Request returned with error code: \(String(describing: response.statusCode))",
                        data: data
                    )
                )
            }
            do {
                let content = try JSONDecoder().decode(T.self, from: data)
                return .success(content)
            } catch {
                print(error)
                return .failure(.parseError(reason: error))
            }
        } catch {
            return .failure(.unknownError(error: error))
        }
    }

}
