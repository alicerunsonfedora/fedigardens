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
    @Environment(\.userProfile) var currentUser
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
                            StatusDetailProfileMenu(
                                displayedProfile: $viewModel.displayedProfile,
                                composer: $viewModel.shouldOpenCompositionTool,
                                account: account
                            )
                        }
                    }

                    Group {
                        if let account = viewModel.status?.reblog?.account, account != viewModel.status?.account {
                            StatusDetailProfileMenu(
                                displayedProfile: $viewModel.displayedProfile,
                                composer: $viewModel.shouldOpenCompositionTool,
                                account: account
                            )
                        }
                    }

                    Group {
                        if let account = viewModel.quote?.account, account != viewModel.status?.account {
                            StatusDetailProfileMenu(
                                displayedProfile: $viewModel.displayedProfile,
                                composer: $viewModel.shouldOpenCompositionTool,
                                account: account
                            )
                        }
                    }

                    Group {
                        if let account = viewModel.quote?.reblog?.account, account != viewModel.status?.account {
                            StatusDetailProfileMenu(
                                displayedProfile: $viewModel.displayedProfile,
                                composer: $viewModel.shouldOpenCompositionTool,
                                account: account
                            )
                        }
                    }

                } label: {
                    Label("status.profileaction.name", systemImage: "person.circle")
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
            ToolbarItem(id: "view-attachments", placement: .primaryAction) {
                Group {
                    let allAttached = viewModel.status?.reblog?.mediaAttachments ?? viewModel.status?.mediaAttachments
                    Button {
                        if let attachments = allAttached, let id = viewModel.status?.id {
                            viewModel.displayAttachments = .init(id: id, attachments: attachments)
                        }
                    } label: {
                        Label("status.attachmentaction", systemImage: "paperclip")
                    }.disabled(allAttached == nil || allAttached?.isEmpty == true)
                }
            }
            .defaultCustomization(options: .alwaysAvailable)

            ToolbarItem(id: "vote-poll", placement: .primaryAction) {
                if let poll = viewModel.status?.poll {
                    Button {
                        viewModel.shouldVote = poll
                    } label: {
                        Label("Vote", systemImage: "text.badge.checkmark")
                    }
                    .disabled(poll.expired == true || poll.voted == true)
                }
            }
            .defaultCustomization(options: .alwaysAvailable)
        }
    }

    private var commonToolbarButtons: some CustomizableToolbarContent {
        Group {
            ToolbarItem(id: "edit", placement: .secondaryAction) {
                if let status = viewModel.status, status.account == currentUser, status.reblog == nil {
                    GardensComposeButton(
                        shouldInvokeParentSheet: $viewModel.shouldOpenCompositionTool,
                        context: AuthoringContext(
                            editablePostID: status.id,
                            prefilledText: status.text ?? status.content.plainTextContents(),
                            pollExpiration: status.getPollExpirationInterval() ?? "",
                            pollOptions: status.getPollOptions() ?? ""
                        ),
                        style: .edit
                    )
                }
            }
            .defaultCustomization(options: .alwaysAvailable)

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
                        participants: UserDefaults.standard.addQuoteParticipant
                        ? "@" + (viewModel.status?.originalAuthor().acct ?? "") : "",
                        visibility: viewModel.status?.visibility ?? .public
                    ),
                    style: .quote
                )
                .help("help.quotestatus")
            }
        }
    }
}
