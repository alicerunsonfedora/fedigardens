//
//  MessagingAuthorView.swift
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

// MARK: - Messaging Author View

/// A view used to author messages to other people in a conversation.
///
/// This differs from ``AuthorView`` in that it uses other settings to write messages. Additionally, it displays no
/// options to change visibilities or apply content warnings at the moment.
struct MessagingAuthorView: View {
    /// The status that the user will be responding to in the conversation.
    @State var replyStatus: Status

    /// The current user's ID.
    @State var currentUserID = "0"

    /// The text of the message that will be sent.
    @State private var text: String = ""

    /// A closure that will be executed when the message was successfully sent.
    var onSubmit: (Status) -> Void

    /// The number of characters remaining.
    private var charactersRemaining: Int { 500 - text.count }

    var body: some View {
        HStack {
            TextField("Message", text: $text)
                .textFieldStyle(.plain)
                .padding(.vertical, 8)
                .padding(.leading, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 0.5)
                )
            Button {
                Task { await submit() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
                    .background(Color.white.clipShape(Circle()))
            }
            .buttonStyle(.borderless)
            .tint(.accentColor)
            .disabled(charactersRemaining < 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(.thickMaterial)
        .onAppear {
            Task {
                await addMessageText()
            }
        }
    }

    /// Inserts the message text into the text field. This will include all of the mentioned users.
    private func addMessageText() async {
        let respondent = "@\(replyStatus.account.acct)"
        let otherMembers = replyStatus.mentions
            .filter { account in account.id != currentUserID }
            .map { mention in "@\(mention.acct)" }
            .filter { name in name != respondent }
            .joined(separator: " ")
        text = "\(respondent) \(otherMembers) "
    }

    /// Attempt to submit a POST request to send the message.
    private func submit() async {
        if charactersRemaining < 0 {
            return
        }

        let params = [
            "status": text,
            "visibility": "direct",
            "poll": "null",
            "in_reply_to_id": replyStatus.id
        ]

        do {
            let composed: Status? = try await Chica.shared
                .request(.post, for: .statuses(id: nil), params: params)
            if let finished = composed {
                onSubmit(finished)
            }
        } catch {
            print("Some other error occurred here.")
            print(error.localizedDescription)
        }
    }
}

// MARK: - Previews

struct MessagingAuthorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.red
                .edgesIgnoringSafeArea(.all)
            MessagingAuthorView(replyStatus: MockData.status!) { _ in }
        }
    }
}
