//
//  StatusDetailToolbar.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/25/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Alice

struct StatusDetailToolbar: CustomizableToolbarContent {
    @Environment(\.deviceModel) var deviceModel
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    @StateObject var viewModel: StatusDetailViewModel
    @Binding var displayUndisclosedContent: Bool

    private var shouldDisplayItem: Bool {
        !deviceModel.starts(with: "iPad")
    }

    var body: some CustomizableToolbarContent {
        Group {
            primaryToolbarButtons
            commonToolbarButtons

            ToolbarItem(id: "favorite", placement: .secondaryAction, showsByDefault: shouldDisplayItem) {
                Button {
                    Task {
                        await viewModel.toggleFavoriteStatus()
                    }
                } label: {
                    Label(
                        "status.likeaction",
                        systemImage: viewModel.status?.favourited == true ? "star.fill" : "star"
                    )
                }
                .help("help.likestatus")
            }
            .defaultCustomization(options: .alwaysAvailable)

            ToolbarItem(id: "safari", placement: .secondaryAction, showsByDefault: shouldDisplayItem) {
                Button {
                    if let url = viewModel.status?.uriToURL() {
                        openURL(url)
                    }
                } label: {
                    Label("Open in Safari", systemImage: "safari")
                }
            }
            .defaultCustomization(options: .alwaysAvailable)

            ToolbarItem(id: "refresh-context", placement: .secondaryAction, showsByDefault: false) {
                Button {
                    Task {
                        await viewModel.getContext()
                    }
                } label: {
                    Label("general.refresh", systemImage: "arrow.clockwise")
                }
                .help("help.refresh")
            }

            ToolbarItem(id: "bookmark", placement: .secondaryAction, showsByDefault: shouldDisplayItem) {
                Button {
                    Task { await viewModel.toggleBookmarkedStatus() }
                } label: {
                    Label(
                        "status.saveaction",
                        systemImage: viewModel.status?.bookmarked == true ? "bookmark.slash" : "bookmark"
                    )
                }.help("help.save")
            }
            .defaultCustomization(options: .alwaysAvailable)

            ToolbarItem(id: "profiles", placement: .secondaryAction, showsByDefault: shouldDisplayItem) {
                Menu {
                    Group {
                        if let account = viewModel.status?.account {
                            Button {
                                viewModel.displayedProfile = account
                            } label: {
                                Label(account.getAccountName(), systemImage: "person.circle")
                            }
                        }
                    }

                    Group {
                        if let account = viewModel.status?.reblog?.account, account != viewModel.status?.account {
                            Button {
                                viewModel.displayedProfile = account
                            } label: {
                                Label(account.getAccountName(), systemImage: "person.circle")
                            }
                        }
                    }

                } label: {
                    Label("status.profileaction.generic", image: "person.circle")
                }
            }
            .defaultCustomization(options: .alwaysAvailable)
        }
    }

    private var primaryToolbarButtons: some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "share", placement: .primaryAction) {
                if let url = viewModel.status?.uriToURL() {
                    ShareLink(item: url)
                }
            }
            ToolbarItem(id: "content-warning", placement: .primaryAction) {
                if viewModel.containsUndisclosedContent {
                    Toggle(isOn: $displayUndisclosedContent) {
                        Label("Toggle Disclosed Content", systemImage: "eye")
                    }
                }
            }
        }
    }

    private var commonToolbarButtons: some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "reply", placement: .secondaryAction) {
                GardensComposeButton(
                    shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                    context: AuthoringContext(
                        replyingToID: viewModel.status?.id ?? "",
                        visibility: viewModel.status?.visibility ?? .public
                    ),
                    style: .reply
                )
                .help("help.replystatus")
            }

            ToolbarItem(id: "reblog", placement: .secondaryAction) {
                Button {
                    Task {
                        await viewModel.toggleReblogStatus()
                    }
                } label: {
                    Label(
                        "status.reblogaction",
                        systemImage: viewModel.status?.reblogged == true
                        ? "arrow.triangle.2.circlepath.circle.fill"
                        : "arrow.triangle.2.circlepath.circle"
                    )
                }
                .help("help.booststatus")
            }

            ToolbarItem(id: "forward", placement: .secondaryAction) {
                GardensComposeButton(
                    shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                    context: .init(
                        forwardingURI: viewModel.status?.uriToURL()?.absoluteString ?? "",
                        visibility: viewModel.status?.visibility ?? .public
                    ),
                    style: .quote
                )
                .help("help.quotestatus")
            }
        }
    }
}
