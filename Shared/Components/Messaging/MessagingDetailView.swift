// 
//  MessageDetailView.swift
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

struct MessagingDetailView: View, LayoutStateRepresentable {

    @State var conversation: Conversation
    @State var currentSenderID: String = ""
    @State private var conversationCtx: Context? = nil
    @State internal var state: LayoutState = .initial
    @State private var text: String = ""
    @State private var recentlyWritten = [Status]()

    var body: some View {
        ZStack {
            conversationView
            if let status = conversation.lastStatus {
                VStack {
                    Spacer()
                    MessagingAuthorView(replyStatus: status, currentUserID: currentSenderID) { newStatus in
                        recentlyWritten.append(status)
                    }
                }
            }
        }
        .frame(minWidth: 300, minHeight: 200)
    }

    var conversationView: some View {
        ScrollView {
            VStack {
                Group {
                    switch state {
                    case .initial, .loading:
                        MessagingPresentationView(
                            messages: MockData.context!,
                            lastMessage: MockData.status!,
                            extras: [],
                            senderID: "0"
                        )
                            .redacted(reason: .placeholder)
                    case .loaded:
                        if let ctx = conversationCtx {
                            MessagingPresentationView(
                                messages: ctx,
                                lastMessage: conversation.lastStatus!,
                                extras: recentlyWritten,
                                senderID: currentSenderID
                            )
                            Spacer()
                                .frame(height: 48)
                        } else {
                            Text("Start The Conversation")
                        }
                    case .errored(let message):
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text(message)
                        }
                    }
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            Task {
                await updateContext()
            }
        }
    }

    func updateContext() async {
        guard let status = conversation.lastStatus else {
            state = .loaded
            return
        }
        state = .loading
        do {
            conversationCtx = try await Chica.shared.request(.get, for: .context(id: status.id))
            state = .loaded
        } catch FetchError.message(let message, _) {
            state = .errored(message: message)
        } catch {
            state = .errored(message: error.localizedDescription)
        }
    }
}

struct MessagingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagingDetailView(conversation: MockData.conversation!)
            MessagingDetailView(conversation: MockData.conversation!)
                .preferredColorScheme(.dark)
        }

    }
}
