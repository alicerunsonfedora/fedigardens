// 
//  StatusDetailToolbar.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/25/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Chica

struct StatusDetailToolbar: CustomizableToolbarContent {
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    @StateObject var viewModel: StatusDetailViewModel
    @Binding var displayUndisclosedContent: Bool

    var body: some CustomizableToolbarContent {
        Group {
            primaryToolbarButtons
            commonToolbarButtons

            ToolbarItem(id: "favorite", placement: .secondaryAction) {
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
            }.defaultCustomization(.hidden)

            ToolbarItem(id: "safari", placement: .secondaryAction) {
                Button {
                    if let url = viewModel.status?.uriToURL() {
                        openURL(url)
                    }
                } label: {
                    Label("Open in Safari", systemImage: "safari")
                }
            }.defaultCustomization(.hidden)

            ToolbarItem(id: "refresh-context", placement: .secondaryAction) {
                Button {
                    Task {
                        await viewModel.getContext()
                    }
                } label: {
                    Label("general.refresh", systemImage: "arrow.clockwise")
                }
                .help("help.refresh")
            }
            .defaultCustomization(.hidden)
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
                Button {
                    let context = AuthoringContext(
                        replyingToID: viewModel.status?.id ?? "",
                        visibility: viewModel.status?.visibility ?? .public
                    )
                    openWindow(value: context)
                } label: {
                    Label("status.replyaction", systemImage: "arrowshape.turn.up.backward")
                }
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
                Button {
                    let context = AuthoringContext(
                        forwardingURI: viewModel.status?.uriToURL()?.absoluteString ?? "",
                        visibility: viewModel.status?.visibility ?? .public
                    )
                    openWindow(value: context)
                } label: {
                    Label("status.forwardaction", systemImage: "quote.bubble")
                }
                .help("help.quotestatus")
            }
        }
    }
}
