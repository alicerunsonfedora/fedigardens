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

struct StatusDisclosedContent: View {
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

    private var mainContent: some View {
        VStack(alignment: .leading) {
            if let rebloggedContent = status.reblog?.content {
                Text(rebloggedContent.attributedHTML())
                    .lineLimit(truncateLines)
                    .textSelection(.enabled)
            } else {
                Text(status.content.attributedHTML())
                    .lineLimit(truncateLines)
                    .textSelection(.enabled)
            }
            if truncateLines == nil {
                StatusMediaDrawer(status: status)
                if let poll = status.poll {
                    StatusPollView(poll: poll)
                }
            }
        }
        .privacySensitive()
    }

    var undisclosedContent: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                if truncateLines == nil {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(
                            String(
                                format: NSLocalizedString("status.spoilermessage", comment: "CW acknowledgement"),
                                status.account.getAccountName(),
                                status.spoilerText
                            ),
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.headline)
                        Text("status.spoilermessage-cta")
                            .font(.subheadline)
                    }
                    .font(.callout)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .tertiarySystemFill).cornerRadius(10))
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
