//
//  MessagingListCellView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 23/2/22.
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

// MARK: - Messaging List Cell

/// A view that displays a single cell in a list of messages.
///
/// This is commonly used in a list of messages to determine what conversation is active.
struct MessagingListCellView: View {
    @Environment(\.userProfile) var currentProfile: Account

    /// The conversation this cell corresponds to.
    var conversation: Conversation

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            conversationImage
            VStack(alignment: .leading) {
                HStack {
                    Text(conversation.getAuthors(excluding: currentProfile.id))
                        .bold()
                        .lineLimit(1)
                    Spacer()
                    if let status = conversation.lastStatus {
                        Text(
                            DateFormatter.mastodon.date(from: status.createdAt)!,
                            format: .relative(presentation: .named)
                        )
                        .foregroundColor(.secondary)
                        .font(.system(.footnote, design: .rounded))
                    }
                }
                Text(conversation.lastStatus?.content.attributedHTML() ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .tint(Color(uiColor: .tertiaryLabel))
            }
        }
    }

    var conversationImage: some View {
        Group {
            if conversation.accounts.count > 2 {
                Image(systemName: "person.3.fill")
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(colors: [Color.blue, Color.indigo], startPoint: .top, endPoint: .bottom)
                    )
            } else {
                if let person = conversation.accounts.last {
                    AsyncImage(url: URL(string: person.avatarStatic)!) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        }
        .clipShape(Circle())
        .frame(width: 40, height: 40)
    }
}

// MARK: - Previews

struct MessagingListCellView_Previews: PreviewProvider {
    static var previews: some View {
        MessagingListCellView(conversation: MockData.conversation!)
            .frame(width: 360, height: 120)
    }
}
