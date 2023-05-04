//
//  StatusDisclosedContent.swift
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

import SwiftUI
import Alice
import EmojiText

struct StatusDisclosedContent: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    @Environment(\.customEmojis) var emojis
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode
    var discloseContent: Bool

    var status: Status
    var truncateLines: Int?

    var body: some View {
        VStack(alignment: .leading) {
            if discloseContent == true {
                mainContent
            } else {
                undisclosedContent
            }
        }
    }

    private var allEmojis: [RemoteEmoji] {
        if enforcedFrugalMode || frugalMode { return [] }
        let emojisFromStatus = status.account.emojis + (status.reblog?.account.emojis ?? [])
        return emojis + emojisFromStatus.map(\.remoteEmoji)
    }

    private var mainContent: some View {
        VStack(alignment: .leading) {
            if let rebloggedContent = status.reblog?.content {
                EmojiText(markdown: rebloggedContent.markdown(), emojis: allEmojis)
                    .lineLimit(truncateLines)
                    .textSelection(.enabled)
            } else {
                EmojiText(markdown: status.content.markdown(), emojis: allEmojis)
                    .lineLimit(truncateLines)
                    .textSelection(.enabled)
            }
            if truncateLines == nil {
                if status.mediaAttachments.isNotEmpty {
                    if enforcedFrugalMode || frugalMode {
                        InformationCard(
                            title: "general.frugalon".localized(),
                            systemImage: "leaf",
                            content: "status.media.frugalon".localized()
                        )
                        .tint(.green)
                        VStack(alignment: .leading) {
                            ForEach(status.mediaAttachments) { attachment in
                                StatusAttachmentAlernative(attachment: attachment)
                            }
                        }
                        .multilineTextAlignment(.leading)
                    } else {
                        AttachmentMediaGroup(status: status)
                    }
                }
                if let poll = status.poll {
                    if poll.expired || poll.voted == true {
                        StatusPollView(poll: poll)
                    } else {
                        PollCallToActionView(author: status.originalAuthor(), poll: poll)
                    }
                }
            }
        }
        .privacySensitive()
    }

    var undisclosedContent: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                if truncateLines == nil {
                    InformationCard(
                        title: "status.spoilermessage".localized(
                            comment: "CW acknowledgement",
                            status.account.getAccountName(),
                            status.spoilerText
                        ),
                        systemImage: "exclamationmark.triangle",
                        content: "status.spoilermessage-cta".localized()
                    )
                    Spacer()
                } else {
                    Label(status.spoilerText, systemImage: "eye.slash")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.secondary)
                }
            }

            mainContent
                .redacted(reason: .privacy)
                .textSelection(.disabled)
        }
    }
}
