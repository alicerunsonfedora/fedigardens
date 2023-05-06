//
//  AliceMockSession.swift
//  
//
//  Created by Marquis Kurt on 5/6/23.
//

import Foundation
import Alice

enum AliceMockError: Error {
    case badRequest
    case unknownEndpoint
    case noMockDataFound
}

extension AliceMockError: LocalizedError {
    var localizedDescription: String {
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

class AliceMockResponse: URLResponse {
    var data: Data?
}

class AliceMockSession {
    typealias MockResponse = AliceMockResponse
    var configuration: URLSessionConfiguration { urlSessionConfiguration }
    private var urlSessionConfiguration: URLSessionConfiguration

    enum Touchpoint: String {
        case status = "https://hyrma.example/api/v1/statuses/105833885501246760"
        case account = "https://hyrma.example/api/v1/accounts/1"
        case apps = "https://hyrma.example/api/v1/apps"
        case oauth = "https://hyrma.example/oauth/token"
        case revoke = "https://hyrma.example/oauth/revoke"
    }

    required init(configuration: URLSessionConfiguration) {
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

    private func unauthorized() -> FetchError {
        guard let data = data(for: "UnauthorizedError") else {
            return .unknownError(error: AliceMockError.noMockDataFound)
        }
        guard let error = try? JSONDecoder().decode(MastodonError.self, from: data) else {
            return .unknown(data: data)
        }
        return .mastodonAPIError(error: error, data: data)
    }
}

extension AliceMockSession: AliceSession {
    func request(_ request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw FetchError.unknownError(error: AliceMockError.badRequest)
        }
        let authenticated = request.allHTTPHeaderFields?["Authorization"]?.starts(with: "Bearer") == true

        switch url.absoluteString {
        case Touchpoint.status.rawValue:
            guard authenticated else { throw unauthorized() }
            return try await requestedSet(for: "Status", to: url)
        case Touchpoint.account.rawValue:
            guard authenticated else { throw unauthorized() }
            return try await requestedSet(for: "Profile", to: url)
        case url.absoluteString where url.absoluteString.starts(with: Touchpoint.apps.rawValue):
            return try await requestedSet(for: "Registration", to: url)
        case url.absoluteString where url.absoluteString.starts(with: Touchpoint.oauth.rawValue):
            return try await requestedSet(for: "Token", to: url)
        case url.absoluteString where url.absoluteString.starts(with: Touchpoint.revoke.rawValue):
            return try await requestedSet(for: "Empty", to: url)
        default:
            throw FetchError.unknownError(error: AliceMockError.unknownEndpoint)
        }
    }
}
