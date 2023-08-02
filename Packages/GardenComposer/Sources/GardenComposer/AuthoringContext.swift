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

/// A structure that defines a context for which an authoring scene can be triggered.
///
/// An authoring context can represent various actions, such as replying to a discussion, creating a quote, or editing a
/// discussion.
public struct AuthoringContext: Codable, Hashable, Identifiable {
    @GardenSetting(key: .defaultVisibility, defaultVisibility: .public)
    static var defaultPostVisibility = PostVisibility.public

    /// The unique identifier for this context.
    public var id = UUID()

    /// The ID of the discussion that is being edited.
    ///
    /// If the context represents a discussion that is being edited, its ID will be used to send a `PUT` request.
    public var editablePostID: String = ""

    /// The URI of the discussion that is being forwarded.
    ///
    /// If a context includes a quote discussion, its originating URI will live here.
    public var forwardingURI: String = ""

    /// The participants in the discussion.
    ///
    /// Participants are represented as account handles (`@johnsmith`).
    public var participants: String = ""

    /// The prefilled contents of the discussion's message.
    ///
    /// This is commonly used in editing contexts or where a reply is fabricated with prefilled content.
    public var prefilledText: String = ""

    /// The ID of the discussion this context will reply to.
    public var replyingToID: String = ""

    /// The suggested post visibility that this discussion will have.
    ///
    /// By default, this is set to the user's default new discussion visibility.
    public var visibility: PostVisibility = AuthoringContext.defaultPostVisibility

    /// The time at which the context's poll will expire.
    ///
    /// This is typically a `TimeInterval` represented as a string, if the context includes a poll.
    public var pollExpiration: String = ""

    /// A comma-separated list of the options the context's poll includes.
    public var pollOptions: String = ""

    /// Creates an authoring context that can be passed around.
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
    /// Creates a context from a supplied URL, starting with `gardens://create`.
    /// - Parameter url: The URL that will be parsed to generate an authoring context.
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

    /// Constructs a URL from the current context, encoding the current values as necessary.
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
    /// Creates a draft by reading an authoring context, taking into account a prompt discussion and the current author.
    ///
    /// - Parameter authoringContext: The authoring context the draft will be created from.
    /// - Parameter prompt: The discussion the context is prompted by, either a reply or quote.
    /// - Parameter author: The current author of the context.
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
    /// Creates an instance of a URL object from an authoring context.
    init?(from context: AuthoringContext) {
        guard let url = context.constructURL() else { return nil }
        self = url
    }
}
