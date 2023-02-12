//
//  PollCallToActionView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/12/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import EmojiText
import Alice

struct PollCallToActionView: View {
    var author: Account
    var poll: Poll

    private var expirationDateString: String {
        guard let expiry = poll.expiresAt, let date = DateFormatter.mastodon.date(from: expiry) else {
            return "infinity"
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        Label {
            VStack(alignment: .leading) {
                EmojiText(
                    markdown: String(
                        format: "status.poll.runningtitle".localized(),
                        author.getAccountName(),
                        expirationDateString
                    ),
                    emojis: author.emojis.map(\.remoteEmoji)
                )
                .font(.headline)
                .bold()
                Text(
                    String(format: "status.poll.runningdetail".localized(), poll.votesCount)
                )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: "checklist")
                .font(.headline)
                .bold()
                .foregroundColor(.accentColor)
        }
    }
}

struct PollCallToActionView_Previews: PreviewProvider {
    static var previews: some View {
        PollCallToActionView(author: MockData.profile!, poll: MockData.poll!)
            .padding()
    }
}
