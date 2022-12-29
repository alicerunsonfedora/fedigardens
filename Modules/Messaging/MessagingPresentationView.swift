//
//  MessagePresentationView.swift
//  Gardens
//
//  Created by Marquis Kurt on 23/2/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import Foundation
import SwiftUI

// MARK: - Message Presentation View

/// A view that displays a list of messages from a specific context.
///
/// This is commonly used to display direct messages from the `lastStatus` property of a conversation.
struct MessagingPresentationView: View {
    @Environment(\.userProfile) var currentUserProfile: Account

    /// The context derived from the messages to render the conversation history from.
    var messages: Context

    /// The last message in the message list.
    var lastMessage: Status

    /// A list of extra statuses to be added to the message list.
    var extras = [Status]()

    var body: some View {
        VStack {
            ForEach(allStatuses(), id: \.id) { message in
                HStack(spacing: 1) {
                    if message.account.id == currentUserProfile.id {
                        Spacer()
                    }

                    MessagePresentationBubble(message: message)
                        .presentationStyle(message.account.id == currentUserProfile.id ? .sender : .recipient)

                    if message.account.id != currentUserProfile.id {
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }

    /// Returns a list of the messages, last message, and extra statuses to be rendered.
    func allStatuses() -> [Status] {
        messages.ancestors + [lastMessage] + extras
    }
}

// MARK: - Message Presentation Bubble

/// A view that shows an individual message bubble.
private struct MessagePresentationBubble: View {
    /// An enumeration for the various presentation styles of a message bubble.
    enum PresentationStyle {
        /// The style applied to messages where the current user is the sender of the message.
        case sender

        /// The style applied to messages where the current user is the recipient of the message.
        case recipient
    }

    /// The message to render into the bubble.
    var message: Status

    /// The presentation style for this message bubble.
    fileprivate var presentationStyle: PresentationStyle

    init(message: Status) {
        self.init(message: message, presentationStyle: .recipient)
    }

    fileprivate init(message: Status, presentationStyle: PresentationStyle) {
        self.message = message
        self.presentationStyle = presentationStyle
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if presentationStyle == .recipient {
                avatar
            }
            Group {
                switch presentationStyle {
                case .sender:
                    baseTextView
                        .background(Color.accentColor.gradient)
                        .foregroundColor(.white)
                        .tint(.white)

                case .recipient:
                    baseTextView
                        .background(Color(uiColor: .tertiarySystemFill).gradient)
                }
            }
            .cornerRadius(16)
            if presentationStyle == .sender {
                avatar
            }
        }
    }

    /// The text view that renders the message contents.
    private var baseTextView: some View {
        Text(message.content.attributedHTML())
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
    }

    private var avatar: some View {
        AsyncImage(url: URL(string: message.account.avatarStatic)!) { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        } placeholder: {
            Image(systemName: "person.circle")
                .imageScale(.large)
        }
        .frame(width: 24, height: 24)
    }
}

private extension MessagePresentationBubble {
    /// Sets the presentation style of the message bubble.
    func presentationStyle(_ presentation: PresentationStyle) -> some View {
        MessagePresentationBubble(message: message, presentationStyle: presentation)
    }
}

// MARK: - Previews

struct MessagePresentationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagingPresentationView(messages: MockData.context!, lastMessage: MockData.status!)
            MessagingPresentationView(messages: MockData.context!, lastMessage: MockData.status!)
                .preferredColorScheme(.dark)
        }
    }
}
