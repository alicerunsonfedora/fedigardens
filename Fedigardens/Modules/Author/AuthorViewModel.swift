//
//  AuthorViewModel.swift
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

import Alice
import Combine
import Drops
import UIKit

class AuthorViewModel: ObservableObject {
    /// The status that the current status will respond to, if the user is replying.
    @Published var prompt: Status?

    /// The body of the status that's being authored.
    @Published var text: String = ""

    /// The visibility of the status. Defaults to public.
    @Published var visibility: Visibility = .public

    /// Whether the post should be marked as sensitive. Defaults to false.
    @Published var sensitive: Bool = false

    /// A prompt content variable used to render the status's text asynchronously.
    @Published var promptContent = "Content goes here."

    /// Associated warning text with a sensitive status context.
    @Published var sensitiveText = ""

    @Published var mentionString = ""

    var userProfile: Account?

    /// The number of characters remaining that the user can utilize.
    var charactersRemaining: Int {
        return calculateCharactersRemaining()
    }

    var textContainsHashtagInReply: Bool {
        let regex = /\#[a-zA-Z0-9]+/
        return prompt != nil && text.matches(of: regex).isNotEmpty
    }

    private var drop: Drop?

    func setAuthor(to account: Account) {
        self.userProfile = account
    }

    func setupTextContents(with context: AuthoringContext) async {
        await self.fetchPromptIfUninitalized(in: context)
        DispatchQueue.main.async {
            self.constructReplyText(with: context.participants)
            self.visibility = context.visibility
            self.drop = self.makeDrop(from: context)
            if !context.forwardingURI.isEmpty {
                self.text.append("💬: \(context.forwardingURI)")
            }
            if context.replyingToID.isNotEmpty {
                self.visibility = .unlisted
            }
        }
    }

    func reformatText(with newText: String) {
        text = newText.count < 600
            ? newText
            : String(newText[...newText.index(newText.startIndex, offsetBy: 600)])
    }

    func submitStatus(completion: @escaping () -> Void) async {
        guard charactersRemaining > 0 else { return }
        var params = [
            "status": mentionString.isNotEmpty ? "\(mentionString) \(text)" : text,
            "visibility": visibility.rawValue,
            "poll": "null"
        ]
        if let reply = prompt { params["in_reply_to_id"] = reply.id }

        if sensitive {
            params["sensitive"] = "true"
            params["spoiler_text"] = sensitiveText
        }

        let response: Alice.Response<Status> = await Alice.shared.request(.post, for: .statuses(), params: params)
        switch response {
        case .success:
            DispatchQueue.main.async {
                if let drop = self.drop {
                    Drops.show(drop)
                }
                completion()
            }
        case .failure(let error):
            print("Post error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                Drops.show(
                    .init(
                        title: "drop.postfailure".localized(comment: "Couldn't post status drop"),
                        subtitle: error.localizedDescription,
                        icon: UIImage(systemName: "exclamationmark.circle")
                    )
                )
            }
        }
    }

    /// Initialized the reply text if there is a prompted status to reply to.
    ///
    /// This will attempt to load in the usernames of the mentioned people in the thread, like most Mastodon
    /// clients do, to maintain consistency and clarity in the conversation thread.
    private func constructReplyText(with existingParticipants: String = "") {
        guard let reply = prompt else {
            mentionString = "\(existingParticipants)"
            return
        }

        var allMentions = reply.mentions
        if let reblogged = reply.reblog { allMentions.append(contentsOf: reblogged.mentions) }

        let otherMembers = memberString(from: allMentions, excluding: reply.account.acct)
        mentionString = reply.account != userProfile ? "@\(reply.account.acct)" : ""
        if otherMembers.isNotEmpty {
            mentionString += " \(otherMembers)"
        }
        if existingParticipants.isNotEmpty {
            mentionString += " \(existingParticipants)"
        }

        // Second pass to add the reblogged author if not included for a given reason.
        if let reblogged = reply.reblog, !allMentions.map(\.acct).contains(reblogged.account.acct),
           reblogged.account != userProfile {
            mentionString += " @\(reblogged.account.acct)"
        }
    }

    private func calculateCharactersRemaining() -> Int {
        do {
            var removedTextString = text
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

            for match in matches {
                guard let range = Range(match.range, in: text) else { continue }
                removedTextString = removedTextString.replacingOccurrences(of: text[range], with: "")
            }

            let mentionRegex = /\@([a-zA-Z0-9\_]+)\@([a-zA-Z0-9\_\-.]+)/
            let usernameCount = mentionString.matches(of: mentionRegex).map { match in match.1.count }
                .reduce(0, +)

            let expectancy = removedTextString.count + (matches.count * 23)
            return 500 - expectancy - usernameCount
        } catch {
            print("Err: couldn't make detector: \(error.localizedDescription). Using naive approach instead.")
            return 500 - text.count
        }
    }

    private func memberString(from members: [Mention], excluding respondentAccount: String) -> String {
        let excluded = [respondentAccount, (userProfile?.acct ?? "")]
        return members.filter { member in !excluded.contains(member.acct) }
            .map { mention in "@\(mention.acct)" }
            .joined(separator: " ")
    }

    private func fetchPromptIfUninitalized(in context: AuthoringContext) async {
        guard !context.replyingToID.isEmpty, prompt == nil else { return }
        let response: Alice.Response<Status> = await Alice.shared.request(
            .get, for: .statuses(id: context.replyingToID)
        )
        switch response {
        case .success(let prompted):
            DispatchQueue.main.async {
                self.prompt = prompted
            }
        case .failure(let error):
            print("Failed to get context: \(error.localizedDescription)")
        }
    }

    private func makeDrop(from context: AuthoringContext) -> Drop {
        if context.replyingToID.isNotEmpty {
            return Drop(
                title: "drop.reply".localized(comment: "Reply drop"),
                icon: UIImage(systemName: "arrowshape.turn.up.left.fill")
            )
        }
        return Drop(title: "drop.post".localized(comment: "Post drop"), icon: UIImage(systemName: "paperplane.fill"))
    }
}
