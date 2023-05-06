//
//  StatusDetailQuote.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/26/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import EmojiText
import SwiftUI

struct StatusDetailQuote: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode
    @State private var expandQuote = false
    @Binding var displayUndisclosedContent: Bool
    var status: Status
    var quote: Status
    var source: Status.QuoteSource

    private var emojis: [RemoteEmoji] {
        if enforcedFrugalMode || frugalMode { return [] }
        return status.emojis.map(\.remoteEmoji) + status.account.emojis.map(\.remoteEmoji)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label {
                EmojiText(
                    markdown: String(
                        format: "status.quotedetect.title".localized(comment: "Quote detected"),
                        status.account.getAccountName()
                    ),
                    emojis: emojis
                )

            } icon: {
                Image(systemName: "quote.bubble")
            }
            .font(.headline)
            .tint(.accentColor)
            EmojiText(
                markdown: String(
                    format: "status.quotedetect.detail".localized(comment: "Quote detected"),
                    status.account.getAccountName(),
                    quote.originalAuthor().getAccountName()
                ).markdown(),
                emojis: emojis
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            if expandQuote {
                StatusView(status: quote)
                    .verifiedNoticePlacement(.byAuthorName)
                    .profileImageSize(32)
                    .reblogNoticePlacement(.hidden)
                    .showsDisclosedContent($displayUndisclosedContent)
            }
            Text(String(format: "status.quotedetect.source".localized(), source.rawValue))
                .font(.footnote)
                .bold()
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }.onTapGesture {
            withAnimation {
                expandQuote.toggle()
            }
        }
        .animation(.easeInOut, value: expandQuote)
    }
}
