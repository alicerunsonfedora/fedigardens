//
//  FedigardensAppLayout.swift
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
import SwiftUI

// MARK: - Widescreen Layout

struct GardensAppWideLayout: View {
    @Environment(\.userProfile) var userProfile: Account
    @StateObject private var viewModel = GardensAppLayoutViewModel()
    @State private var shouldDisplayComposeModal = false

    var body: some View {
        NavigationSplitView {
            List(selection: $viewModel.currentPage) {
                GardensPageLink(page: .forYou)
                GardensPageLink(page: .local)
                GardensPageLink(page: .public)
                GardensPageLink(page: .messages)
                GardensPageLink(page: .selfPosts)
                GardensPageLink(page: .mentions)
                GardensPageLink(page: .saved)
                GardensPageLink(page: .settings)

                if !viewModel.lists.isEmpty {
                    Section {
                        ForEach(viewModel.lists) { list in
                            NavigationLink(value: GardensAppPage.list(id: list.id)) {
                                Label(list.title, systemImage: "folder")
                            }
                        }
                    } header: {
                        Text(GardensAppPage.list(id: "0").localizedTitle)
                    }
                }

                if !viewModel.tags.isEmpty {
                    Section {
                        ForEach(viewModel.tags) { tag in
                            NavigationLink(value: GardensAppPage.trending(id: tag.name)) {
                                Label(tag.name, systemImage: "tag")
                            }
                        }
                    } header: {
                        Text(GardensAppPage.trending(id: "0").localizedTitle)
                    }
                }
            }
            .navigationTitle("general.appname")
            .listStyle(.sidebar)
        } content: {
            sidebarContent
                .toolbar {
                    ToolbarItem {
                        GardensComposeButton(style: .new)
                    }
                }
        } detail: {
            if let selectedStatus = viewModel.selectedStatus {
                StatusDetailView(status: selectedStatus, level: .parent)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "quote.bubble")
                    Text("general.nopost")
                }
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(.secondary)
            }
        }
        .onAppear {
            Task { await viewModel.fetchTags() }
            Task { await viewModel.fetchLists() }
        }
        .sheet(isPresented: $shouldDisplayComposeModal) {
            Text("Hi")
        }
    }

    private var sidebarContent: some View {
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

// MARK: - Previews

struct WidescreenLayout_Previews: PreviewProvider {
    static var previews: some View {
        GardensAppWideLayout()
            .frame(minWidth: 900, minHeight: 500)
    }
}
