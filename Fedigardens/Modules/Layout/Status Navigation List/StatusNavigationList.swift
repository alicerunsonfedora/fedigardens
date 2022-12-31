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
    @Environment(\.openWindow) private var openWindow
    @State var statuses: [Status]
    @Binding var selectedStatus: Status?
    @StateObject private var viewModel: StatusNavigationListViewModel = .init()

    var extras: (() -> Extras)?

    var body: some View {
        List(selection: $selectedStatus) {
            ForEach(viewModel.statuses, id: \.uuid) { status in
                NavigationLink(value: status) {
                    HStack(alignment: .top) {
                        if status.bookmarked == true {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.indigo)
                                .font(.caption)
                        } else if status.favourited == true {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        } else {
                            Image(systemName: "circle.fill")
                                .opacity(0)
                                .font(.caption)
                        }
                        statusLink(for: status)
                            .allowsHitTesting(false)
                    }
                }
            }
            if let extras {
                extras()
            }
        }
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
                    context: AuthoringContext(forwardingURI: status.uriToURL()?.absoluteString ?? ""),
                    style: .quote
                ).tint(.indigo)
            }
            .contextMenu {
                menu(for: status)
            }
    }

    private func menu(for status: Status) -> some View {
        Group {
            Button {
                openWindow(value: status)
            } label: {
                Label("general.newwindow", systemImage: "rectangle.badge.plus")
            }
            GardensComposeButton(
                shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                context: AuthoringContext(replyingToID: status.id),
                style: .reply
            )
            GardensComposeButton(
                shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                context: AuthoringContext(forwardingURI: status.uriToURL()?.absoluteString ?? ""),
                style: .quote
            )
            Button {
                Task {
                    await viewModel.toggleBookmark(status: status)
                }
            } label: {
                Label("status.saveaction", systemImage: "bookmark")
            }
            if let url = status.uriToURL() {
                ShareLink(item: url)
            }
        }
    }
}

// MARK: - Previews

struct StatusListMDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatusNavigationList(
                statuses: MockData.timeline!,
                selectedStatus: .constant(nil)
            ) { EmptyView() }
        }
        .frame(minWidth: 700)
    }
}
