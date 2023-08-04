//
//  AliceMockSession.swift
//  
//
//  Created by Marquis Kurt on 5/6/23.
//

import Foundation
import Alice

public enum AliceMockError: Error {
    case badRequest
    case unknownEndpoint
    case noMockDataFound
}

extension AliceMockError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .badRequest:
            return "The request received was malformed."
        case .unknownEndpoint:
            return "The mock service is unable to recognize the endpoint."
        case .noMockDataFound:
            return "No mock data was found for the endpoint in question."
        }
    }
}

public class AliceMockResponse: URLResponse {
    public var data: Data?
}

public class AliceMockSession {
    public typealias MockResponse = AliceMockResponse
    public var configuration: URLSessionConfiguration { urlSessionConfiguration }
    public var rewriteUnknownHostsToMockHost = true
    private var urlSessionConfiguration: URLSessionConfiguration

    public enum Touchpoint: String {
        case newStatus = "https://hyrma.example/api/v1/statuses"
        case status = "https://hyrma.example/api/v1/statuses/105833885501246760"
        case account = "https://hyrma.example/api/v1/accounts/1"
        case apps = "https://hyrma.example/api/v1/apps"
        case oauth = "https://hyrma.example/oauth/token"
        case revoke = "https://hyrma.example/oauth/revoke"
    }

    public required init(configuration: URLSessionConfiguration) {
        self.urlSessionConfiguration = configuration
    }

    private func data(for mockResource: String) -> Data? {
        guard let mockPath = Bundle.module.path(forResource: mockResource, ofType: "json") else {
            return nil
        }
        let url = URL(filePath: mockPath)
        return try? Data(contentsOf: url)
    }

    private func response(from url: URL, code: Int = 200) -> HTTPURLResponse? {
        HTTPURLResponse(url: url, statusCode: code, httpVersion: "1.1", headerFields: nil)
    }

    private func requestedSet(for mock: String, to url: URL) async throws -> (Data, URLResponse) {
        guard let data = data(for: mock) else {
            throw FetchError.unknownError(error: AliceMockError.noMockDataFound)
        }
        guard let response = response(from: url) else {
            let fakedResp = MockResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            fakedResp.data = data
            throw FetchError.unknownResponseError(response: fakedResp)
        }
        return (data, response)
    }

    private func requestedSet(data: Data, to url: URL) async throws -> (Data, URLResponse) {
        guard let response = response(from: url) else {
            let fakedResp = MockResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            fakedResp.data = data
            throw FetchError.unknownResponseError(response: fakedResp)
        }
        return (data, response)
    }

    private func unauthorized() -> FetchError {
        guard let data = data(for: "UnauthorizedError") else {
            return .unknownError(error: AliceMockError.noMockDataFound)
        }
        guard let error = try? JSONDecoder().decode(MastodonError.self, from: data) else {
            return .unknown(data: data)
        }
        return .mastodonAPIError(error: error, data: data)
    }

    private func validateStatusPost(url: URL) async -> Data? {
        guard let queryParameters = url.queryParameters else {
            return data(for: "UnprocessableEntity")
        }
        if !queryParameters.keys.contains("status") { return data(for: "UnprocessableEntity") }
        if queryParameters["status", default: ""].isEmpty {
            return data(for: "UnprocessableEntity")
        }

        var nullifiedPoll = false
        let requiredParams = ["poll[options][]", "poll[expires_in]"]
        for (key, value) in queryParameters where key.starts(with: "poll") {
            switch (key, value) {
            case ("poll", "null"):
                nullifiedPoll = true
            case (key, _):
                if nullifiedPoll || !requiredParams.contains(key) { return data(for: "UnprocessableEntity") }
            default:
                break
            }
        }

        return nil
    }
}

extension AliceMockSession: AliceSession {
    public func request(_ request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard var url = request.url else {
            throw FetchError.unknownError(error: AliceMockError.badRequest)
        }
        let authenticated = request.allHTTPHeaderFields?["Authorization"]?.starts(with: "Bearer") == true

        if url.host() != "https://hyrma.example", rewriteUnknownHostsToMockHost {
            var baseURL = "https://hyrma.example\(url.path())"
            if let params = url.query() {
                baseURL.append(contentsOf: "?\(params)")
            }
            url = URL(string: baseURL)!
        }
        return try await provideRequestedData(url: url, authenticated: authenticated, method: request.httpMethod)
    }

    func provideRequestedData( // swiftlint:disable:this cyclomatic_complexity
        url: URL,
        authenticated: Bool,
        method: String? = "GET") async throws -> (Data, URLResponse) {
        switch (method, url.absoluteString) {
        case ("GET", Touchpoint.status.rawValue):
            guard authenticated else { throw unauthorized() }
            return try await requestedSet(for: "Status", to: url)
        case ("POST", url.absoluteString) where url.absoluteString.starts(with: Touchpoint.newStatus.rawValue):
            guard authenticated else { throw unauthorized() }
            if let data = await validateStatusPost(url: url) {
                return try await requestedSet(data: data, to: url)
            }
            return try await requestedSet(for: "Status", to: url)
        case ("GET", Touchpoint.account.rawValue):
            guard authenticated else { throw unauthorized() }
            return try await requestedSet(for: "Profile", to: url)
        case ("POST", url.absoluteString) where url.absoluteString.starts(with: Touchpoint.apps.rawValue):
            return try await requestedSet(for: "Registration", to: url)
        case ("POST", url.absoluteString) where url.absoluteString.starts(with: Touchpoint.oauth.rawValue):
            return try await requestedSet(for: "Token", to: url)
        case ("POST", url.absoluteString) where url.absoluteString.starts(with: Touchpoint.revoke.rawValue):
            return try await requestedSet(for: "Empty", to: url)
        default:
            throw FetchError.unknownError(error: AliceMockError.unknownEndpoint)
        }
    }
}
