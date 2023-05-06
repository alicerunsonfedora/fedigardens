//
//  AttachmentViewerToolbar.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/5/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import SwiftUI

struct AttachmentViewerToolbar: ToolbarContent {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AttachmentViewerViewModel

    var body: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: viewModel.toggleContentMode) {
                    Label("", systemImage: viewModel.systemImageForContentMode())
                }
            }
            ToolbarItem {
                Group {
                    if viewModel.didAcknowledgeConsent {
                        if let url = viewModel.currentAttachment?.url {
                            ShareLink(item: url)
                        }
                    } else {
                        Button {
                            viewModel.shouldDisplayConsentAcknowledgementAlert.toggle()
                        } label: {
                            Label("general.share", systemImage: "square.and.arrow.up.trianglebadge.exclamationmark")
                        }
                    }
                }
            }
            ToolbarItem {
                Button {
                    if let url = URL(string: viewModel.currentAttachment?.url ?? "") {
                        openURL(url)
                    }
                } label: {
                    Label("general.browseraction", systemImage: "safari")
                }
            }
            ToolbarItem {
                Button(action: dismiss.callAsFunction) {
                    Text("general.done")
                        .bold()
                }
            }
        }
    }
}
