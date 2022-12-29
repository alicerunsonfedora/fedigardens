// 
//  Chica+CustomRequest.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/26/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Chica

public class GlamrockChica {
    public typealias Response<T: Decodable> = Result<T, ChicaError>
    static let shared = GlamrockChica()

    public enum ChicaError: Error {
        case malformedURL
        case quoteNotFound
        case fetchError(FetchError)
    }

    func requestQuote(of status: Status) async throws -> Status? {
        guard let (quoteDomain, quoteID) = status.quotedReply() else { return nil }
        let requestString = "\(quoteDomain)/api/v1/statuses/\(quoteID)"
        guard let quoteURL = URL(string: requestString) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: quoteURL))
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                throw FetchError.message(
                    reason: "Request returned with error code: " +
                    (String(describing: (response as? HTTPURLResponse)?.statusCode)),
                    data: data
                )
            }
            do {
                return try JSONDecoder().decode(Status.self, from: data)
            } catch {
                throw FetchError.parseError(reason: error)
            }
        } catch {
            throw FetchError.unknownError(error: error)
        }
    }

    func requestQuote(of status: Status) async -> Response<Status> {
        guard let (quoteDomain, quoteID) = status.quotedReply() else {
            return .failure(.quoteNotFound)
        }
        let requestString = "\(quoteDomain)/api/v1/statuses/\(quoteID)"
        guard let quoteURL = URL(string: requestString) else {
            return .failure(.malformedURL)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: quoteURL))
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                return .failure(
                    .fetchError(
                        .message(
                            reason: "Request returned with error code: " +
                            (String(describing: (response as? HTTPURLResponse)?.statusCode)),
                            data: data
                        )
                    )
                )
            }
            do {
                let status = try JSONDecoder().decode(Status.self, from: data)
                return .success(status)
            } catch {
                return .failure(.fetchError(.parseError(reason: error)))
            }
        } catch {
            return .failure(.fetchError(.unknownError(error: error)))
        }
    }
}
