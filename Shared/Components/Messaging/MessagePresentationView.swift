// 
//  MessagePresentationView.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 23/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import SwiftUI
import Chica

// MARK: - Message Presentation View

/// A view that displays a list of messages from a specific context.
///
/// This is commonly used to display direct messages from the `lastStatus` property of a conversation.
struct MessagePresentationView: View {

    /// The context derived from the messages to render the conversation history from.
    @State var messages: Context

    /// The ID of the current user who acts as the "sender" of messages when typing into the text field.
    @State var senderID = ""

    var body: some View {
        VStack {
            ForEach(messages.ancestors, id: \.id) { message in
                HStack(spacing: 1) {
                    if message.account.id == senderID {
                        Spacer()
                    }

                    MessagePresentationBubble(message: message)
                        .presentationStyle(message.account.id == senderID ? .sender : .recipient)

                    if message.account.id != senderID {
                        Spacer()
                    }
                }
            }
        }
        .padding()

    }
}

// MARK: - Message Presentation Bubble

/// A view that shows an individual message bubble.
fileprivate struct MessagePresentationBubble: View {

    /// An enumeration for the various presentation styles of a message bubble.
    enum PresentationStyle {

        /// The style applied to messages where the current user is the sender of the message.
        case sender

        /// The style applied to messages where the current user is the recipient of the message.
        case recipient
    }

    /// The message to render into the bubble.
    @State var message: Status

    /// The presentation style for this message bubble.
    @State fileprivate var presentationStyle: PresentationStyle

    /// The text content of the message.
    @State private var content = "Message content goes here."

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
                AsyncImage(url: URL(string: message.account.avatarStatic)!) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
                .frame(width: 32, height: 32)
            }
            Group {
                switch presentationStyle {
                case .sender:
                    baseTextView
                        .background(Color.accentColor)
                        .foregroundColor(.white)

                case .recipient:
                    baseTextView
                        .background(Color.secondary.opacity(0.5))
                }
            }
            .cornerRadius(16)
        }
    }

    /// The text view that renders the message contents.
    private var baseTextView: some View {
        Text(content)
            .padding()
            .onAppear {
                Task {
                    content = await message.content.toPlainText()
                }
            }
    }
}

fileprivate extension MessagePresentationBubble {

    /// Sets the presentation style of the message bubble.
    func presentationStyle(_ presentation: PresentationStyle) -> some View {
        MessagePresentationBubble(message: self.message, presentationStyle: presentation)
    }
}

// MARK: - Previews

struct MessagePresentationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagePresentationView(messages: MockData.context!, senderID: "2")
            MessagePresentationView(messages: MockData.context!, senderID: "2")
                .preferredColorScheme(.dark)
        }

    }
}
