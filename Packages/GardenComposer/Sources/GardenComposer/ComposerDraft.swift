//
//  ComposerDraft.swift
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

/// A structure that represents a discussion draft.
///
/// A draft is typically used with flows that integrate with discussion composition and can be created from an
/// ``AuthoringContext``.
public struct ComposerDraft {
    /// Whether the draft contains sensitive information that requires a content warning.
    public var containsSensitiveInformation: Bool

    /// The contents of the discussion.
    ///
    /// - Note: To retrieve the current number of characters a draft occupies, use ``count`` instead of `content.count`.
    public var content: String

    /// The two-character localization code that represents the language the current draft is written in.
    public var localizationCode: String

    /// A string containing the participants in a discussion.
    ///
    /// Mentions may include other discussion participants from a thread, original authors from quoted discussions, and
    /// original authors of reblogged content. This field can be treated as the 'Cc:' line of a discussion.
    public var mentions: String

    /// A draft poll, if the draft includes one.
    public var poll: ComposerDraftPoll?

    /// The discussion that this draft either replies to or is quoting.
    public var prompt: Status?

    /// The contents of the prompted discussion.
    public var promptContent: String

    /// The ID of the current discussion, if it has already been published.
    ///
    /// If this value is not `nil`, it indicates that the draft represents a discussion that has been published already,
    /// but the user is wishing to edit its contents.
    public var publishedStatusID: String?

    /// The summary of the content warning.
    ///
    /// If ``containsSensitiveInformation`` is enabled, this message will be used as the content warning when publishing
    /// the discussion.
    public var sensitiveDisclaimer: String

    /// The visibility level which this discussion will be published as.
    public var visibility: PostVisibility

    /// Creates a draft for the composer.
    public init(containsSensitiveInformation: Bool = false,
                content: String = "",
                localizationCode: String = "en",
                mentions: String = "",
                poll: ComposerDraftPoll? = nil,
                prompt: Status? = nil,
                promptContent: String = "",
                publishedStatusID: String? = nil,
                sensitiveDisclaimer: String = "",
                visibility: PostVisibility = .public) {
        self.containsSensitiveInformation = containsSensitiveInformation
        self.content = content
        self.localizationCode = localizationCode
        self.mentions = mentions
        self.poll = poll
        self.prompt = prompt
        self.promptContent = promptContent
        self.publishedStatusID = publishedStatusID
        self.sensitiveDisclaimer = sensitiveDisclaimer
        self.visibility = visibility
    }

    /// Creates a new draft for the composer.
    /// - Parameter contents: The contents of the new draft.
    /// - Parameter visibility: The visibility level which this discussion will be published as. The `public` visibility
    ///   is used as the default.
    public init(new contents: String, visibility: PostVisibility = .public) {
        self.init(content: contents, visibility: visibility)
    }

    /// The current number of characters the draft's contents occupies.
    ///
    /// The count property uses the same counting algorithm as a Mastodon server to better reflect character limits
    /// Mastodon community servers impose.
    ///
    /// If ``content`` contains any URLs, each URL will account for 23 characters per URL, rather than the full length
    /// of the URL's absolute string. For example, the following content counts as 44 characters total:
    /// ```
    /// Testing https://www.google.com is that kool
    /// ```
    ///
    /// If ``content`` contains any mentioned participants, or if ``mentions`` is not empty, only the usernames
    /// contribute to the count, rather than the full handle (i.e., `@johnsmith` instead of `@johnsmith@apple.social`).
    /// For example, the following content counts as 47 characters:
    /// ```
    /// Let's mention @Gargron@mastodon.social in this reply, shall we?
    /// ```
    ///
    /// - Note: In the event that an NSDataDetector cannot be generated for the current content, the content's string
    ///   count is returned instead. However, this rarely occurs. Use ``count`` instead of `content.count` for a
    ///   consistent character count.
    public var count: Int {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            var textStrippedFromUrls = content + mentions
            let matches = detector.matches(in: content,
                                           options: [],
                                           range: NSRange(location: 0, length: content.utf16.count))
                .filter { match in
                    guard let substring = match.text(in: content),
                          let url = URL(string: String(substring)) else { return false }
                    return url.scheme != nil
                }
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                textStrippedFromUrls = textStrippedFromUrls.replacingCharacters(in: range, with: "")
            }

            var matchedMentions = mentions.matches(of: Status.mentionRegex)
            matchedMentions += content.matches(of: Status.mentionRegex)
            matchedMentions.map(\.output).forEach { output in
                textStrippedFromUrls = textStrippedFromUrls.replacingOccurrences(of: output.0, with: "@\(output.1)")
            }
            let charactersWithoutLinks = textStrippedFromUrls.count + (matches.count * 23)
            return charactersWithoutLinks
        } catch {
            print("Err: couldn't make detector: \(error.localizedDescription). Using naive approach instead.")
            return content.count
        }
    }
}

/// A structure that represents a poll being drafted.
public struct ComposerDraftPoll {
    /// The options included in this poll.
    public var options: [String]

    /// The date at which the poll will expire.
    /// - Note: This should be set at least five minutes from the current draft date.
    public var expirationDate: Date = .now.advanced(by: 300)

    /// Creates a draft poll.
    public init(options: [String], expirationDate: Date) {
        self.options = options
        self.expirationDate = expirationDate
    }
}

extension ComposerDraftPoll: Equatable, Hashable {}
extension ComposerDraft: Equatable, Hashable {}
