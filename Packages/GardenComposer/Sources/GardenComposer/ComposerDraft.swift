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

public struct ComposerDraft {
    public var containsSensitiveInformation: Bool
    public var content: String
    public var localizationCode: String
    public var mentions: String
    public var poll: ComposerDraftPoll?
    public var prompt: Status?
    public var promptContent: String
    public var publishedStatusID: String?
    public var sensitiveDisclaimer: String
    public var visibility: PostVisibility

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

    public init(new contents: String, visibility: PostVisibility = .public) {
        self.init(content: contents, visibility: visibility)
    }

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

public struct ComposerDraftPoll {
    public var options: [String]
    public var expirationDate: Date = .now.advanced(by: 300)

    public init(options: [String], expirationDate: Date) {
        self.options = options
        self.expirationDate = expirationDate
    }
}
