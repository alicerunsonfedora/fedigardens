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
    public typealias OAuth = AuthenticationModule

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
        if INSTANCE_DOMAIN.isEmpty {
            INSTANCE_DOMAIN = "mastodon.online"
            return URL(string: "https://mastodon.online")!
        }
        return URL(string: "https://\(INSTANCE_DOMAIN)")!
    }

    /// Allows us to decode top-level values of the given type from the given JSON representation.
    private let decoder: JSONDecoder

    private var session: AliceSession

    public var urlPrefix: String

    private var oauthStateCancellable: AnyCancellable?

    //  MARK: - INITIALIZERS

    public init<Session: AliceSession>(using sessionType: Session.Type = URLSession.self) {
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

        self.session = Session(configuration: configuration)
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
            let request = Self.makeRequest(method, url: url, params: params)
            let (data, response) = try await self.session.request(request, delegate: nil)

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

    public func get<T: Decodable>(_ endpoint: Endpoint, params: [String: String]? = nil) async -> Response<T> {
        return await request(.get, for: endpoint, params: params)
    }

    public func post<T: Decodable>(_ endpoint: Endpoint, params: [String: String]? = nil) async -> Response<T> {
        return await request(.post, for: endpoint, params: params)
    }

    public func put<T: Decodable>(_ endpoint: Endpoint, params: [String: String]? = nil) async -> Response<T> {
        return await request(.put, for: endpoint, params: params)
    }

    public func delete<T: Decodable>(_ endpoint: Endpoint, params: [String: String]? = nil) async -> Response<T> {
        return await request(.delete, for: endpoint, params: params)
    }
}
