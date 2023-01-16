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

import SwiftUI
import Alice

struct StatusDetailQuote: View {
    @State private var expandQuote = false
    @Binding var displayUndisclosedContent: Bool
    var status: Status
    var quote: Status
    var source: Status.QuoteSource

    var body: some View {
        VStack(alignment: .leading) {
            Label(
                String(
                    format: "status.quotedetect.title".localized(comment: "Quote detected"),
                    status.account.getAccountName()
                ),
                systemImage: "quote.bubble"
            )
            .font(.headline)
            .tint(.accentColor)
            Text(
                String(
                    format: "status.quotedetect.detail".localized(comment: "Quote detected"),
                    status.account.getAccountName(),
                    quote.originalAuthor().getAccountName()
                )
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
