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
import SwiftUI
import Bunker

class AuthorViewModel: ObservableObject {
    @Published var editMode = false
    @Published var includesPoll = false
    @Published var mentionString = ""
    @Published var pollExpirationDate: Date = .now.advanced(by: 300)
    @Published var pollOptions = ["", ""]
    @Published var prompt: Status?
    @Published var promptContent = "Content goes here."
    @Published var selectedLanguage = "en"
    @Published var sensitive: Bool = false
    @Published var sensitiveText = ""
    @Published var statusID = ""
    @Published var text: String = ""
    @Published var visibility: PostVisibility = UserDefaults.standard.defaultVisibility

    var userProfile: Account?

    var availableLanguageCodes: [String] {
        Locale.LanguageCode.isoLanguageCodes.filter { code in
            code.identifier.count == 2
        }.map(\.identifier)
    }

    var charactersRemaining: Int {
        return calculateCharactersRemaining()
    }

    var submittableText: String {
        mentionString.isNotEmpty ? [mentionString, text].joined(separator: " ") : text
    }

    var proposedNavigationTitle: LocalizedStringKey {
        if editMode {
            return "status.edit"
        }
        if prompt != nil {
            return "status.newreply"
        }
        return "status.new"
    }

    var textContainsHashtagInReply: Bool {
        let regex = /\#[a-zA-Z0-9]+/
        return prompt != nil && text.matches(of: regex).isNotEmpty
    }

    var shouldDisableSubmission: Bool {
        UserDefaults.standard.enforceCharacterLimit && charactersRemaining < 0
    }

    private var drop: Drop?

    func setAuthor(to account: Account) {
        self.userProfile = account
    }

    func setupTextContents(with context: AuthoringContext) async {
        await self.fetchPromptIfUninitalized(in: context)
        DispatchQueue.main.async {
            if context.prefilledText.isNotEmpty {
                self.text = context.prefilledText
            }
            self.constructReplyText(with: context.participants)
            self.visibility = context.visibility
            self.drop = self.makeDrop(from: context)
            if context.forwardingURI.isNotEmpty {
                self.text.append("💬: \(context.forwardingURI)")
                self.visibility = UserDefaults.standard.defaultQuoteVisibility
            }
            if context.replyingToID.isNotEmpty {
                self.visibility = UserDefaults.standard.defaultReplyVisibility
            }
            if context.editablePostID.isNotEmpty {
                self.editMode = true
                self.statusID = context.editablePostID
            }

            if context.pollExpiration.isNotEmpty, context.pollOptions.isNotEmpty {
                self.includesPoll = true
                let expirationDate = TimeInterval(context.pollExpiration)
                self.pollExpirationDate = Date.now.advanced(by: expirationDate ?? 300)
                self.pollOptions = context.pollOptions.split(separator: ",").map { String($0) }
            }
        }
    }

    func submitStatus(completion: @escaping () -> Void) async {
        if UserDefaults.standard.enforceCharacterLimit, charactersRemaining < 0 { return }
        let params = constructParameters()
        guard params["status", default: ""] == submittableText else { return }
        let requestMethod: Alice.Method = editMode ? .put : .post
        let endpoint: Endpoint = .statuses(id: editMode ? statusID : nil)

        let response: Alice.Response<Status> = await Alice.shared.request(requestMethod, for: endpoint, params: params)
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

    private func constructParameters() -> [String: String] {
        let fullStatus = mentionString.isNotEmpty ? [mentionString, text].joined(separator: " ") : text

        var params = ["status": fullStatus, "language": selectedLanguage]
        if !editMode { params["visibility"] = visibility.rawValue }
        if let reply = prompt { params["in_reply_to_id"] = reply.id }
        if sensitive {
            params["sensitive"] = "true"
            params["spoiler_text"] = sensitiveText
        }

        if includesPoll {
            params["poll[options][]"] = pollOptions.joined(separator: ",")
            params["poll[expires_in]"] = String(pollExpirationDate.timeIntervalSinceNow.rounded())
        } else {
            params["poll"] = "null"
        }

        return params
    }

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
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            var textStrippedFromUrls = text + mentionString
            let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
                .filter { match in
                    guard let substring = match.text(in: text),
                          let url = URL(string: String(substring)) else { return false }
                    return url.scheme != nil
                }
            for match in matches {
                guard let range = Range(match.range, in: text) else { continue }
                textStrippedFromUrls = textStrippedFromUrls.replacingCharacters(in: range, with: "")
            }

            var mentions = mentionString.matches(of: Status.mentionRegex)
            mentions += text.matches(of: Status.mentionRegex)
            mentions.map(\.output).forEach { output in
                textStrippedFromUrls = textStrippedFromUrls.replacingOccurrences(of: output.0, with: "@\(output.1)")
            }
            let charactersWithoutLinks = textStrippedFromUrls.count + (matches.count * 23)
            return UserDefaults.standard.characterLimit - (charactersWithoutLinks)
        } catch {
            print("Err: couldn't make detector: \(error.localizedDescription). Using naive approach instead.")
            return UserDefaults.standard.characterLimit - text.count
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
        let response: Alice.Response<Status> = await Alice.shared.get(.statuses(id: context.replyingToID))
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
                icon: .init(systemName: "arrowshape.turn.up.left.fill")
            )
        }
        if editMode {
            return Drop(title: "drop.edit".localized(comment: "Edit drop"), icon: .init(systemName: "pencil"))
        }
        return Drop(title: "drop.post".localized(comment: "Post drop"), icon: UIImage(systemName: "paperplane.fill"))
    }
}
