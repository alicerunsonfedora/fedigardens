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
import Bunker

struct AuthoringContext: Codable, Hashable, Identifiable {
    var id = UUID()
    var editablePostID: String = ""
    var forwardingURI: String = ""
    var participants: String = ""
    var prefilledText: String = ""
    var replyingToID: String = ""
    var visibility: Visibility = .public
    var pollExpiration: String = ""
    var pollOptions: String = ""
}

extension AuthoringContext {
    init?(from url: URL) {
        guard url.absoluteString.starts(with: "gardens://create"), let params = url.queryParameters else { return nil }
        self = AuthoringContext(
            editablePostID: params["statusID", default: ""],
            forwardingURI: params["forwardURI", default: ""],
            participants: params["participants", default: ""],
            prefilledText: params["status", default: ""],
            replyingToID: params["replyID", default: ""],
            visibility: Visibility(rawValue: params["visibility", default: "public"]) ?? .public,
            pollExpiration: params["poll[expires_in]", default: ""],
            pollOptions: params["poll[options][]", default: ""]
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

        if editablePostID.isNotEmpty {
            query.append(.init(name: "statusID", value: editablePostID))
        }

        if prefilledText.isNotEmpty {
            query.append(.init(name: "status", value: prefilledText))
        }

        if pollExpiration.isNotEmpty {
            query.append(.init(name: "poll[expires_in]", value: pollExpiration))
        }

        if pollOptions.isNotEmpty {
            query.append(.init(name: "poll[options][]", value: pollOptions))
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
