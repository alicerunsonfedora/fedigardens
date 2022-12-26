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
import Chica

struct StatusDetailQuote: View {
    @Binding var displayUndisclosedContent: Bool
    var status: Status
    var quote: Status

    var body: some View {
        VStack(alignment: .leading) {
            Label(
                String(
                    format: NSLocalizedString("status.quotedetect.title", comment: "Quote detected"),
                    status.account.getAccountName()
                ),
                systemImage: "quote.bubble"
            )
            .font(.headline)
            .tint(.accentColor)
            Text(
                String(
                    format: NSLocalizedString("status.quotedetect.detail", comment: "Quote detected"),
                    status.account.getAccountName(),
                    quote.originalAuthor().getAccountName()
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            StatusView(status: quote)
                .lineLimit(3)
                .profileImageSize(24)
                .reblogNoticePlacement(.hidden)
                .showsDisclosedContent($displayUndisclosedContent)
        }
    }
}
