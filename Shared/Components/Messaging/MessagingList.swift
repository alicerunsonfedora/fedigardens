//
//  MessagingList.swift
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

import Chica
import enum Chica.Visibility
import Foundation
import SwiftUI

// MARK: - Messaging List

/// A view that represents a list of messages.
///
/// This is commonly used to display a conversation list in the "Messages" section of the app. The design is
/// primarily inspired by Apple's Messages app.
struct MessagingList: View, LayoutStateRepresentable {
    @Environment(\.openURL) var openURL

    /// The list of conversations the user is a part of.
    @State private var conversations: [Conversation]?

    /// The current state of the view's layout.
    @State internal var state: LayoutState = .initial

    /// Whether the author view should be open to create a new message.
    ///
    /// This defaults to `false`, and will only be marked `true` on iOS with a button press.
    @State private var composeStatus: Bool = false

    /// The current user that is logged into the app.
    @State private var currentAcct: Account?

    var body: some View {
        Group {
            switch state {
            case .initial, .loading:
                List {
                    ForEach(0 ..< 7) { _ in
                        MessagingListCellView(conversation: MockData.conversation!, currentUserID: "0")
                    }
                }
                .redacted(reason: .placeholder)
                .frame(minWidth: 250, idealWidth: 300)
            case .loaded:
                List {
                    if let convos = conversations {
                        ForEach(convos, id: \.id) { conversation in
                            NavigationLink {
                                MessagingDetailView(
                                    conversation: conversation,
                                    currentSenderID: currentAcct?.id ?? "0"
                                )
                                .navigationTitle(
                                    conversation.getAuthors(excluding: currentAcct?.id ?? "0")
                                )
                            } label: {
                                MessagingListCellView(
                                    conversation: conversation,
                                    currentUserID: currentAcct?.id ?? "0"
                                )
                            }
                            .padding(4)
                        }
                    }
                }
                .frame(minWidth: 250, idealWidth: 300)
            case .errored(let message):
                Text("\(message)")
            }
        }
        .onAppear {
            Task {
                await getCurrentAccount()
                await getConversations()
            }
        }
#if os(iOS)
        .refreshable {
            Task {
                await getConversations(forcefully: true)
            }
        }
        .sheet(isPresented: $composeStatus) {
            NavigationView {
                AuthorView(visibility: .direct)
            }
            .navigationViewStyle(.stack)
        }
#endif
        .toolbar {
            ToolbarItem {
                Button {
#if os(macOS)
                    if let url = URL(string: "shout://create") {
                        openURL(url)
                    }
#else
                    composeStatus.toggle()
#endif
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .help("help.poststatus")
            }
            ToolbarItem {
                Button {
                    Task { await getConversations(forcefully: true) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("help.refresh")
            }
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
            do {
                state = .loading
                conversations = try await Chica.shared.request(.get, for: .timeline(scope: .messages))
                state = .loaded
            } catch FetchError.message(let reason, _) {
                state = .errored(message: reason)
            } catch {
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

    /// Retrieves the current user account.
    private func getCurrentAccount() async {
        if currentAcct != nil { return }
        do {
            currentAcct = try await Chica.shared.request(.get, for: .verifyAccountCredentials)
        } catch FetchError.message(let reason, let data) {
            print("Error: \(reason)")
            print(String(data: data, encoding: .utf8) ?? "")
        } catch FetchError.unknown(let data) {
            print(String(data: data, encoding: .utf8) ?? "")
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Previews

struct MessagingList_Previews: PreviewProvider {
    static var previews: some View {
        MessagingList()
    }
}
