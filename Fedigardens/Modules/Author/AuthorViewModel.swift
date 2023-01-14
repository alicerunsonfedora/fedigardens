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

import Foundation
import Combine
import Alice

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

    /// The number of characters remaining that the user can utilize.
    var charactersRemaining: Int {
        return calculateCharactersRemaining()
    }

    func setupTextContents(with context: AuthoringContext) async {
        await self.fetchPromptIfUninitalized(in: context)
        DispatchQueue.main.async {
            self.constructReplyText(with: context.participants)
            self.visibility = context.visibility
            if !context.forwardingURI.isEmpty {
                self.text.append("💬: \(context.forwardingURI)")
            }
        }
    }

    func reformatText(with newText: String) {
        text = newText.count <= 500
            ? newText
            : String(newText[...newText.index(newText.startIndex, offsetBy: 500)])
    }

    func submitStatus(completion: @escaping () -> Void) async {
        guard charactersRemaining > 0 else { return }
        var params = ["status": text, "visibility": visibility.rawValue, "poll": "null"]
        if let reply = prompt { params["in_reply_to_id"] = reply.id }

        if sensitive {
            params["sensitive"] = "true"
            params["spoiler_text"] = sensitiveText
        }

        let response: Alice.Response<Status> = await Alice.shared.request(.post, for: .statuses(), params: params)
        switch response {
        case .success:
            completion()
        case .failure(let error):
            print("Post error: \(error.localizedDescription)")
        }
    }

    /// Initialized the reply text if there is a prompted status to reply to.
    ///
    /// This will attempt to load in the usernames of the mentioned people in the thread, like most Mastodon
    /// clients do, to maintain consistency and clarity in the conversation thread.
    private func constructReplyText(with existingParticipants: String = "") {
        if let reply = prompt {
            var allMentions = reply.mentions
            if let reblogged = reply.reblog { allMentions.append(contentsOf: reblogged.mentions) }
            let otherMembers = memberString(from: allMentions, excluding: reply.account.acct)
            text = "@\(reply.account.acct) \(otherMembers) \(existingParticipants) "
            return
        }
        text = "\(existingParticipants)"
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

            let expectancy = removedTextString.count + (matches.count * 23)
            return 500 - expectancy
        } catch {
            print("Err: couldn't make detector: \(error.localizedDescription). Using naive approach instead.")
            return 500 - text.count
        }
    }

    private func memberString(from members: [Mention], excluding respondentAccount: String) -> String {
        members.filter { member in member.acct != respondentAccount }
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
}
