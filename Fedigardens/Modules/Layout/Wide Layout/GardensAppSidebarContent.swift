//
//  GardensAppSidebarContent.swift
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

struct GardensAppSidebarContent: View {
    @Environment(\.userProfile) var userProfile
    @StateObject var viewModel: GardensAppLayoutViewModel

    var body: some View {
        Group {
            if let destination = viewModel.currentPage {
                Group {
                    switch destination {
                    case .forYou:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .home, local: false),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationTitle(GardensAppPage.forYou.localizedTitle)
                    case .local:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .network, local: true),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationTitle(GardensAppPage.local.localizedTitle)
                    case .public:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .network, local: false),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationTitle(GardensAppPage.public.localizedTitle)
                    case .messages:
                        MessagingList()
                            .navigationTitle(GardensAppPage.messages.localizedTitle)
                    case .saved:
                        TimelineSplitView(scope: .saved, selectedStatus: $viewModel.selectedStatus)
                            .navigationTitle(GardensAppPage.saved.localizedTitle)
                    case .selfPosts:
                        TimelineSplitView(
                            scope: .profile(id: userProfile.id),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationTitle(GardensAppPage.selfPosts.localizedTitle)
                    case .mentions:
                        InteractionsListView(selectedStatus: $viewModel.selectedStatus)
                            .navigationTitle(GardensAppPage.mentions.localizedTitle)
                    case .list(let id):
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .list(id: id), local: false),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationBarTitleDisplayMode(.inline)
                    case .trending(let id):
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .tag(tag: id), local: false),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationTitle("#\(id)")
                    case .settings:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                    Text("general.nopage")
                }
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(.secondary)
            }
        }
    }
}
