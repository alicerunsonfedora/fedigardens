//
//  AuthorViewContext.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/25/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Alice

struct AuthoringContext: Codable, Hashable, Identifiable {
    var id = UUID()
    var replyingToID: String = ""
    var forwardingURI: String = ""
    var participants: String = ""
    var visibility: Visibility = .public
}

extension AuthoringContext {
    init?(from url: URL) {
        guard url.absoluteString.starts(with: "gardens://create"), let params = url.queryParameters else { return nil }
        self = AuthoringContext(
            replyingToID: params["replyID"] ?? "",
            forwardingURI: params["forwardURI"] ?? "",
            participants: params["participants"] ?? "",
            visibility: Visibility(rawValue: params["visibility"] ?? "public") ?? .public
        )
    }

    func constructURL() -> URL? {
        guard let url = URL(string: "gardens://create") else { return nil }
        var query = [URLQueryItem]()

        if replyingToID.isNotEmpty {
            query.append(.init(name: "replyID", value: replyingToID))
        }

        if forwardingURI.isNotEmpty {
            query.append(.init(name: "forwardURI", value: forwardingURI))
        }

        if participants.isNotEmpty {
            query.append(.init(name: "participants", value: participants))
        }

        query.append(.init(name: "visibility", value: visibility.rawValue))
        return url.appending(queryItems: query)
    }
}

extension URL {
    init?(from context: AuthoringContext) {
        guard let url = context.constructURL() else { return nil }
        self = url
    }
}
