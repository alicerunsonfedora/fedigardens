//
//  ComposeButton.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct GardensComposeButton: View {
    enum ComposeStyle {
        case new
        case reply
        case quote
        case feedback
        case mention
        case message
    }

    @Environment(\.supportsMultipleWindows) var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openURL) private var openURL

    var shouldInvokeParentSheet: Binding<AuthoringContext?>?

    @State private var shouldOpenAsSheet = false

    var context: AuthoringContext = .init()
    var style: ComposeStyle

    var body: some View {
        Group {
            Button {
                if supportsMultipleWindows {
                    openWindow(value: context)
                } else if let shouldInvokeParentSheet {
                    shouldInvokeParentSheet.wrappedValue = context
                } else {
                    shouldOpenAsSheet.toggle()
                }
            } label: {
                composeLabel
            }
            .help("help.poststatus")
        }
        .sheet(isPresented: $shouldOpenAsSheet) {
            NavigationStack {
                AuthorView(authoringContext: context)
            }
        }
    }

    var composeLabel: some View {
        Group {
            switch style {
            case .new:
                Label("status.compose", systemImage: "square.and.pencil")
            case .reply:
                Label("status.replyaction", systemImage: "arrowshape.turn.up.backward")
            case .quote:
                Label("status.forwardaction", systemImage: "quote.bubble")
            case .feedback:
                Label("settings.feedback.message", systemImage: "bubble.left")
            case .mention:
                Label("status.mentionaction", systemImage: "at.badge.plus")
            case .message:
                Label("status.messageaction", systemImage: "text.bubble")
            }
        }
    }
}
