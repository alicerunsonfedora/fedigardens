//
//  ProfileSheetToolbar.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/15/23.
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

struct ProfileSheetToolbar: ToolbarContent {
    @AppStorage(.preferMatrixConversations) var prefersMatrixConversations = true
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ProfileSheetViewModel

    var body: some ToolbarContent {
        Group {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("general.done", systemImage: "xmark")
                }
                .labelStyle(.titleOnly)
            }

            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task {
                        await viewModel.toggleFollow()
                    }
                } label: {
                    Label(
                        viewModel.relationship?.following == true
                            ? "profile.unfollowaction" : "profile.followaction",
                        systemImage: viewModel.relationship?.following == true
                            ? "person.badge.minus" : "person.badge.plus"
                    )
                }
            }
            ToolbarItem(placement: .bottomBar) {
                GardensComposeButton(style: .mention)
            }
            ToolbarItem(placement: .bottomBar) {
                if prefersMatrixConversations, viewModel.profile?.matrixID() != nil {
                    Button(action: viewModel.startMatrixConversation) {
                        Label {
                            Text("profile.matrixaction")
                        } icon: {
                            Text("[m]")
                                .bold()
                        }
                    }
                } else {
                    GardensComposeButton(style: .message)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    Task {
                        await viewModel.toggleMute()
                    }
                } label: {
                    Label(
                        viewModel.relationship?.muting == true ? "profile.muteaction" : "profile.unmuteaction",
                        systemImage: viewModel.relationship?.muting == true
                            ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.moon.fill"
                    )
                }
            }
        }
    }
}
