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
    }

    class Keychain: AliceSecurityModule {
        private var keychain = [String: String]()

        func setSecureStore(_ value: String?, forKey key: String) {
            keychain[key] = value
        }

        func getSecureStore(_ key: String) -> String? {
            return keychain[key]
        }
    }

    required init(configuration: URLSessionConfiguration) {
        self.urlSessionConfiguration = configuration
    }

    private func data(for mockResource: String) -> Data? {
        guard let mockPath = Bundle(for: AliceMockSession.self).path(forResource: mockResource, ofType: "json") else {
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
}

extension AliceMockSession: AliceSession {
    func request(_ request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw FetchError.unknownError(error: AliceMockError.badRequest)
        }

        switch url.absoluteString {
        case Touchpoint.status.rawValue:
            return try await requestedSet(for: "Status", to: url)
        case Touchpoint.account.rawValue:
            return try await requestedSet(for: "Account", to: url)
        case url.absoluteString where url.absoluteString.starts(with: Touchpoint.apps.rawValue):
            return try await requestedSet(for: "Registration", to: url)
        default:
            throw FetchError.unknownError(error: AliceMockError.unknownEndpoint)
        }
    }
}
