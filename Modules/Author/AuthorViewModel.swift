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
import Chica

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
    var charactersRemaining: Int { 500 - text.count }

    func setupTextContents(with context: AuthoringContext) async {
        if !context.replyingToID.isEmpty, prompt == nil {
            let newPrompt: Status? = try? await Chica.shared.request(.get, for: .statuses(id: context.replyingToID))
            DispatchQueue.main.async {
                self.prompt = newPrompt
            }
        }
        
        DispatchQueue.main.async {
            self.constructReplyText()
            self.visibility = context.visibility

            if !context.forwardingURI.isEmpty {
                self.text.append("💬: \(context.forwardingURI)")
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
        var params = ["status": text, "visibility": visibility.rawValue, "poll": "null"]
        if let reply = prompt {
            params["in_reply_to_id"] = reply.id
        }

        if sensitive {
            params["sensitive"] = "true"
            params["spoiler_text"] = sensitiveText
        }

        do {
            let _: Status? = try await Chica.shared
                .request(.post, for: .statuses(id: nil), params: params)
            completion()
        } catch {
            print("Some other error occurred here.")
            print(error.localizedDescription)
        }
    }

    /// Initialized the reply text if there is a prompted status to reply to.
    ///
    /// This will attempt to load in the usernames of the mentioned people in the thread, like most Mastodon
    /// clients do, to maintain consistency and clarity in the conversation thread.
    private func constructReplyText() {
        guard let reply = prompt else { return }
        let respondent = "@\(reply.account.acct)"
        var otherMembers = reply.mentions
            .map { mention in "@\(mention.acct)" }
            .filter { name in name != respondent }
            .joined(separator: " ")
        if let reblogged = reply.reblog {
            otherMembers += " " + reblogged.mentions
                .map { mention in "@\(mention.acct)" }
                .filter { name in name != respondent }
                .joined(separator: " ")
        }
        text = "\(respondent) \(otherMembers) "
    }
}
