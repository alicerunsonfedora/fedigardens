//
//  StatusListMDView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 11/2/22.
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

// MARK: - Status Navigation List
struct StatusNavigationList<Extras: View>: View {
    typealias ViewModel = StatusNavigationListViewModel
    @Environment(\.enforcedFrugalMode) private var enforcedFrugalMode
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @AppStorage(.useFocusedInbox) private var useFocusedInbox: Bool = false
    @AppStorage(.frugalMode) private var frugalMode: Bool = false
    @State var statuses: [Status]
    @Binding var selectedStatus: Status?
    @StateObject private var viewModel = ViewModel()

    var extras: (() -> Extras)?

    var body: some View {
        List(selection: $selectedStatus) {
            Group {
                if useFocusedInbox {
                    Picker("inbox", selection: $viewModel.inbox) {
                        ForEach(ViewModel.InboxPage.allCases, id: \.hashValue) { inbox in
                            Label(inbox.rawValue.localized(), systemImage: inbox.icon)
                                .tag(inbox)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowSeparator(.hidden)
                }
                if enforcedFrugalMode || frugalMode {
                    Label("general.frugalon", systemImage: "leaf.fill")
                        .bold()
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.green)
                        .listRowSeparator(.hidden)
                }
            }

            ForEach(viewModel.statuses, id: \.uuid) { status in
                NavigationLink(value: status) {
                    VStack(alignment: .trailing) {
                        statusLink(for: status)
                            .allowsHitTesting(false)
                        StatusQuickGlanceView(status: status)
                    }
                }
            }
            if let extras {
                extras()
            }
        }
        .animation(.spring(), value: viewModel.inbox)
        .onAppear {
            viewModel.insert(statuses: statuses)
        }
        .sheet(item: $viewModel.shouldOpenCompositionTool) { context in
            NavigationStack {
                AuthorView(authoringContext: context)
            }
        }
    }

    private func statusLink(for status: Status) -> some View {
        StatusView(status: status)
            .lineLimit(2)
            .profilePlacement(.hidden)
            .datePlacement(.automatic)
            .profileImageSize(44)
            .verifiedNoticePlacement(.byAuthorName)
            .tint(.secondary)
            .swipeActions(edge: .leading) {
                Button {
                    Task {
                        await viewModel.toggleFavorite(status: status)
                    }
                } label: {
                    Label("status.likeaction", systemImage: "star")
                }.tint(.yellow)
                Button {
                    Task {
                        await viewModel.toggleBookmark(status: status)
                    }
                } label: {
                    Label("status.saveaction", systemImage: "bookmark")
                }.tint(.indigo)
            }
            .swipeActions {
                GardensComposeButton(
                    shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                    context: AuthoringContext(replyingToID: status.id),
                    style: .reply)
                    .tint(.accentColor)

                GardensComposeButton(
                    shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                    context: AuthoringContext(
                        forwardingURI: status.uriToURL()?.absoluteString ?? "",
                        participants: UserDefaults.standard.addQuoteParticipant
                        ? "@\(status.originalAuthor().acct)" : ""
                    ),
                    style: .quote
                ).tint(.indigo)
            }
            .contextMenu {
                menu(for: status)
            }
    }

    private func menu(for status: Status) -> some View {
        Group {
            if supportsMultipleWindows {
                Button {
                    openWindow(value: status)
                } label: {
                    Label("general.newwindow", systemImage: "rectangle.badge.plus")
                }
                Divider()
            }
            Button {
                Task {
                    await viewModel.toggleFavorite(status: status)
                }
            } label: {
                Label("status.likeaction", systemImage: "star")
            }
            Button {
                Task {
                    await viewModel.toggleBookmark(status: status)
                }
            } label: {
                Label("status.saveaction", systemImage: "bookmark")
            }
            Divider()
            GardensComposeButton(
                shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                context: AuthoringContext(replyingToID: status.id),
                style: .reply
            )
            GardensComposeButton(
                shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                context: AuthoringContext(
                    forwardingURI: status.uriToURL()?.absoluteString ?? "",
                    participants: UserDefaults.standard.addQuoteParticipant
                    ? "@\(status.originalAuthor().acct)" : ""
                ),
                style: .quote
            )
            if let url = status.uriToURL() {
                Divider()
                Link(destination: url) {
                    Label("status.webaction", systemImage: "safari")
                }
                ShareLink(item: url)
            }
        }
    }
}

// MARK: - Previews

struct StatusListMDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StatusNavigationList(statuses: MockData.timeline!, selectedStatus: .constant(nil)) { EmptyView() }
                .listStyle(.plain)
                .navigationTitle("Inbox")
        }
    }
}
