//
//  MessagingList.swift
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
import enum Alice.Visibility
import Foundation
import SwiftUI

// MARK: - Messaging List

/// A view that represents a list of messages.
///
/// This is commonly used to display a conversation list in the "Messages" section of the app. The design is
/// primarily inspired by Apple's Messages app.
struct MessagingList: View, LayoutStateRepresentable {
    @Environment(\.userProfile) private var currentAcct: Account

    /// The list of conversations the user is a part of.
    @State private var conversations: [Conversation]?

    /// The current state of the view's layout.
    @State internal var state: LayoutState = .initial

    var body: some View {
        Group {
            switch state {
            case .initial, .loading:
                List {
                    messagesDisclaimerNotice
                    ForEach(0 ..< 7) { _ in
                        MessagingListCellView(conversation: MockData.conversation!)
                    }
                    .redacted(reason: .placeholder)
                }
            case .loaded:
                List {
                    messagesDisclaimerNotice
                    if let convos = conversations {
                        ForEach(convos, id: \.id) { conversation in
                            NavigationLink {
                                MessagingDetailView(conversation: conversation)
                                .navigationTitle(conversation.getAuthors(excluding: currentAcct.id))
                            } label: {
                                MessagingListCellView(conversation: conversation)
                            }
                            .padding(4)
                        }
                    }
                }
            case .errored(let message):
                Text("\(message)")
            }
        }
        .listStyle(.inset)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await getConversations()
            }
        }
        .refreshable {
            Task {
                await getConversations(forcefully: true)
            }
        }
    }

    private var messagesDisclaimerNotice: some View {
        VStack(alignment: .leading) {
            Label("direct.nonencrypt.title", systemImage: "info.circle")
                .bold()
            Text("direct.nonencrypt.detail")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
    }

    /// Load the list of conversations into the view.
    /// - Parameter forcefully: Whether to forcefully reload the data, regardless if the conversation list is already
    ///     loaded. Defaults to false.
    ///
    /// Typically, this method is called when rendering the view for the first time to fetch the conversations list.
    /// Since the network call is asynchronous, this method has been made asynchronous.
    ///
    /// - Important: Only forcefully reload data when the user requests it. This call may be expensive on the network
    ///     and may take time to re-fetch the data into memory.
    private func getConversations(forcefully: Bool = false) async {
        func makeRequest() async {
            state = .loading
            let response: Alice.Response<[Conversation]> = await Alice.shared.get(.timeline(scope: .messages))
            switch response {
            case .success(let conversations):
                DispatchQueue.main.async {
                    self.conversations = conversations
                }
                state = .loaded
            case .failure(let error):
                if case FetchError.message(let reason, _) = error {
                    state = .errored(message: reason)
                    return
                }
                state = .errored(message: error.localizedDescription)
            }
        }

        if forcefully {
            await makeRequest()
            return
        }
        switch state {
        case .loaded:
            return
        default:
            await makeRequest()
        }
    }
}

// MARK: - Previews

struct MessagingList_Previews: PreviewProvider {
    static var previews: some View {
        MessagingList()
    }
}
