//
//  GardensAppCompactSidebar.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/21/23.
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

struct GardensAppCompactSidebarContent: View {
    @Environment(\.userProfile) var userProfile: Account
    @StateObject var viewModel: GardensAppLayoutViewModel
    @Binding var currentPage: GardensAppPage?

    var body: some View {
        Group {
            if let destination = currentPage {
                switch destination {
                case .public:
                    TimelineSplitView(
                        scope: .scopedTimeline(scope: .network, local: false),
                        selectedStatus: $viewModel.selectedStatus
                    )
                    .navigationTitle("endpoint.latest")
                    .toolbar {
                        ToolbarItem {
                            GardensComposeButton(style: .new)
                        }
                    }
                case .messages:
                    MessagingList()
                        .navigationTitle(GardensAppPage.messages.localizedTitle)
                case .saved:
                    TimelineSplitView(scope: .saved, selectedStatus: $viewModel.selectedStatus)
                        .navigationTitle("endpoint.saved")
                        .toolbar {
                            ToolbarItem {
                                GardensComposeButton(style: .new)
                            }
                        }
                case .selfPosts:
                    TimelineSplitView(
                        scope: .profile(id: userProfile.id),
                        selectedStatus: $viewModel.selectedStatus
                    )
                    .navigationTitle("endpoint.selfposts")
                    .toolbar {
                        ToolbarItem {
                            GardensComposeButton(style: .new)
                        }
                    }
                case .settings:
                    SettingsView()
                        .navigationTitle("general.settings")
                case .list(let id):
                    TimelineSplitView(
                        scope: .scopedTimeline(scope: .list(id: id), local: false),
                        selectedStatus: $viewModel.selectedStatus
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem {
                            GardensComposeButton(style: .new)
                        }
                    }
                case .trending(let id):
                    TimelineSplitView(
                        scope: .scopedTimeline(scope: .tag(tag: id), local: false),
                        selectedStatus: $viewModel.selectedStatus
                    )
                    .navigationTitle("#\(id)")
                    .toolbar {
                        ToolbarItem {
                            GardensComposeButton(style: .new)
                        }
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}
