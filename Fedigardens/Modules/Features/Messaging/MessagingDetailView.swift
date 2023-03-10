//
//  MessageDetailView.swift
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

// MARK: - Messaging Detail View

/// A view that represents the detail view of a master-detail view for messaging.
///
/// This is commonly used to display a message thread.
struct MessagingDetailView: View, LayoutStateRepresentable {
    /// The corresponding conversation the detail view will render.
    var conversation: Conversation

    /// The current state of the view's layout.
    @State internal var state: LayoutState = .initial

    @State private var text: String = ""

    /// A list of messages that were recently written by the current user.
    @State private var recentlyWritten = [Status]()

    @StateObject var viewModel = MessagingDetailViewModel()

    var body: some View {
        ZStack {
            conversationView
            if let status = conversation.lastStatus {
                VStack {
                    Spacer()
                    MessagingAuthorView(
                        replyStatus: status,
                        writtenMessages: $recentlyWritten
                    )
                }
            }
        }
        .frame(minWidth: 300, minHeight: 200)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            Task {
                state = await viewModel.replaceConversation(with: conversation)
            }
        }
        .onChange(of: conversation) { newValue in
            state = .loading
            Task {
                state = await viewModel.replaceConversation(with: newValue)
                recentlyWritten.removeAll()
            }
        }
        .refreshable {
            state = .loading
            Task {
                state = await viewModel.fetchContext(of: nil)
                recentlyWritten.removeAll()
            }
        }
    }

    var conversationView: some View {
        ScrollView(.vertical) {
            VStack {
                Group {
                    switch state {
                    case .initial, .loading:
                        MessagingPresentationView(
                            messages: MockData.context!,
                            lastMessage: MockData.status!,
                            extras: []
                        )
                        .redacted(reason: .placeholder)
                    case .loaded:
                        if let ctx = viewModel.context {
                            MessagingPresentationView(
                                messages: ctx,
                                lastMessage: conversation.lastStatus!,
                                extras: recentlyWritten
                            )
                            Spacer()
                                .frame(height: 48)
                        } else {
                            Text("Start The Conversation")
                        }
                    case .errored(let message):
                        VStack {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text(message)
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
    }
}

// MARK: - Previews

struct MessagingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagingDetailView(conversation: MockData.conversation!)
            MessagingDetailView(conversation: MockData.conversation!)
                .preferredColorScheme(.dark)
        }
    }
}
