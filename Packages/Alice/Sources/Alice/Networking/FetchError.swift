//
//  FetchError.swift
//  Chica
//
//  Created by Alex Modroño Vara on 18/7/21.
//

import Foundation

/// Represents an error that might be returned when doing a HTTP request.
///
/// Inspired in NetworkError by **Thomas Ricouard** in https://github.com/Dimillian/RedditOS
public enum FetchError: Error {
    case unknown(data: Data)
    case unknownError(error: Error)
    case unknownResponseError(response: URLResponse)
    case message(reason: String, data: Data)
    case parseError(reason: Error)
    case mastodonAPIError(error: MastodonError, data: Data)
    
    static private let decoder = JSONDecoder()
    
    static func processResponse(data: Data, response: URLResponse) throws -> Data {

        //  First, we try to convert the httpResponse to HTTPURLResponse
        //  if it fails, it means the http error is unknown, hence, we return it as .unknown
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FetchError.unknown(data: data)
        }

        //  Really straight-forward: if the error is 404, we already know what it means...
        if (httpResponse.statusCode == 404) {
            throw FetchError.message(reason: "Resource not found", data: data)
        }

        if 200 ... 299 ~= httpResponse.statusCode {

            return data

        } else {

            do {

                let mastodonError = try decoder.decode(MastodonError.self, from: data)

                throw FetchError.mastodonAPIError(error: mastodonError, data: data)

            } catch _ {

                throw FetchError.unknown(data: data)

            }
        }
    }
}

extension FetchError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknownError(let error):
            return "\(error)"
        default:
            return "Use \"FetchError.processResponse()\" to get more information."
        }
    }
}
