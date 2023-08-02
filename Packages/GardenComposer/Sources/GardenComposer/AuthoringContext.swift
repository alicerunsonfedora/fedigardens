//
//  AuthorViewContext.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/8/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import Foundation
import GardenSettings

public struct AuthoringContext: Codable, Hashable, Identifiable {
    @GardenSetting(key: .defaultVisibility, defaultVisibility: .public)
    static var defaultPostVisibility = PostVisibility.public

    public var id = UUID()
    public var editablePostID: String = ""
    public var forwardingURI: String = ""
    public var participants: String = ""
    public var prefilledText: String = ""
    public var replyingToID: String = ""
    public var visibility: PostVisibility = AuthoringContext.defaultPostVisibility
    public var pollExpiration: String = ""
    public var pollOptions: String = ""

    public init(editablePostID: String = "",
                forwardingURI: String = "",
                participants: String = "",
                prefilledText: String = "",
                replyingToID: String = "",
                visibility: PostVisibility? = nil,
                pollExpiration: String = "",
                pollOptions: String = "") {
        self.id = UUID()
        self.editablePostID = editablePostID
        self.forwardingURI = forwardingURI
        self.participants = participants
        self.prefilledText = prefilledText
        self.replyingToID = replyingToID
        self.visibility = visibility ?? AuthoringContext.defaultPostVisibility
        self.pollExpiration = pollExpiration
        self.pollOptions = pollOptions
    }
}

public extension AuthoringContext {
    init?(from url: URL) {
        guard url.absoluteString.starts(with: "gardens://create"), let params = url.queryParameters else { return nil }
        self = AuthoringContext(
            editablePostID: params["statusID", default: ""],
            forwardingURI: params["forwardURI", default: ""],
            participants: params["participants", default: ""],
            prefilledText: params["status", default: ""],
            replyingToID: params["replyID", default: ""],
            visibility: PostVisibility(rawValue: params["visibility", default: "public"]) ?? .public,
            pollExpiration: params["poll[expires_in]", default: ""],
            pollOptions: params["poll[options][]", default: ""]
        )
    }

    func constructURL() -> URL? {
        guard let url = URL(string: "gardens://create") else { return nil }
        var query = [URLQueryItem]()

        if !replyingToID.isEmpty {
            query.append(.init(name: "replyID", value: replyingToID))
        }

        if !forwardingURI.isEmpty {
            query.append(.init(name: "forwardURI", value: forwardingURI))
        }

        if !participants.isEmpty {
            query.append(.init(name: "participants", value: participants))
        }

        if !editablePostID.isEmpty {
            query.append(.init(name: "statusID", value: editablePostID))
        }

        if !prefilledText.isEmpty {
            query.append(.init(name: "status", value: prefilledText))
        }

        if !pollExpiration.isEmpty {
            query.append(.init(name: "poll[expires_in]", value: pollExpiration))
        }

        if !pollOptions.isEmpty {
            query.append(.init(name: "poll[options][]", value: pollOptions))
        }

        query.append(.init(name: "visibility", value: visibility.rawValue))
        return url.appending(queryItems: query)
    }
}

public extension ComposerDraft {
    init(authoringContext: AuthoringContext, promptedBy prompt: Status, author: Account) {
        var constructedText = authoringContext.prefilledText
        var draftPoll: ComposerDraftPoll?

        if !authoringContext.forwardingURI.isEmpty {
            constructedText.append("💬: \(authoringContext.forwardingURI)")
        }

        if !authoringContext.pollExpiration.isEmpty, !authoringContext.pollOptions.isEmpty {
            let timeInterval = TimeInterval(authoringContext.pollExpiration)
            draftPoll = .init(
                options: authoringContext.pollOptions.split(separator: ",").map(String.init),
                expirationDate: Date.now.advanced(by: timeInterval ?? 300))
        }

        self.init(content: constructedText,
                  mentions: prompt.replyMentions(excluding: author),
                  poll: draftPoll,
                  publishedStatusID: authoringContext.editablePostID.isEmpty ? nil : authoringContext.editablePostID,
                  visibility: authoringContext.visibility)
    }
}

public extension URL {
    init?(from context: AuthoringContext) {
        guard let url = context.constructURL() else { return nil }
        self = url
    }
}
