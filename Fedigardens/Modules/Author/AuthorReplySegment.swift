//
//  AuthorReplySegment.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 17/2/22.
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
import SwiftUI

/// A view that displays a status that will be replied to.
struct AuthorReplySegment: View {
    /// The status that the user will reply to.
    @State var reply: Status

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "text.bubble")
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    String(
                        format: NSLocalizedString("status.replytext", comment: "reply"),
                        reply.account.getAccountName() + " (@\(reply.account.acct))"
                    )
                )
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.accentColor)
                .bold()
                StatusView(status: reply)
                    .datePlacement(.underContent)
                    .showsDisclosedContent(.constant(true))
                    .profilePlacement(.hidden)
                    .lineLimit(3)
            }
            .foregroundColor(.secondary)
        }
    }
}
