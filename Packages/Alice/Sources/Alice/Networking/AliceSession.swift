//
//  AliceSession.swift
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

import Foundation

public protocol AliceSession {
    var configuration: URLSessionConfiguration { get }
    init(configuration: URLSessionConfiguration)
    func request(_ request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: AliceSession {
    public func request(
        _ request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, URLResponse) {
        return try await data(for: request, delegate: delegate)
    }
}
