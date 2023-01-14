//
//  GardensAppCompactLayout.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/6/23.
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

struct GardensAppCompactLayout: View {
    @Environment(\.userProfile) var userProfile: Account
    @StateObject private var viewModel = GardensAppLayoutViewModel()
    @State private var shouldDisplayComposeModal = false
    @State private var path: [Status] = []

    var body: some View {
        TabView {
            rootTab(for: .scopedTimeline(scope: .home, local: false), page: .forYou)
            rootTab(for: .scopedTimeline(scope: .network, local: true), page: .local)
            NavigationSplitView {
                InteractionsListView(selectedStatus: $viewModel.selectedStatus)
                    .navigationTitle(GardensAppPage.mentions.localizedTitle)
                    .listStyle(.inset)
            } detail: {
                navigationDetailView
            }
                .tabItem {
                Label(page: .mentions)
            }
            NavigationStack {
                MessagingList()
                    .navigationTitle(GardensAppPage.messages.localizedTitle)
            }
            .tabItem {
                Label(page: .messages)
            }
            moreView
                .tabItem { Label("general.more", systemImage: "ellipsis.circle") }
        }
        .onAppear {
            viewModel.currentPage = nil
            Task { await viewModel.fetchTags() }
            Task { await viewModel.fetchLists() }
        }
    }

    private func rootTab(
        for scope: TimelineSplitViewModel.TimelineType,
        page: GardensAppPage
    ) -> some View {
        NavigationSplitView {
            TimelineSplitView(scope: scope, selectedStatus: $viewModel.selectedStatus)
            .listStyle(.inset)
            .navigationTitle(page.localizedTitle)
            .toolbar {
                ToolbarItem {
                    GardensComposeButton(style: .new)
                }
            }
        } detail: {
            navigationDetailView
        }
        .tabItem {
            Label(page: page)
        }
    }

    private var navigationDetailView: some View {
        Group {
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
    }

    private var moreView: some View {
        NavigationSplitView {
            List(selection: $viewModel.currentPage) {
                GardensPageLink(page: .public)
                GardensPageLink(page: .selfPosts)
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
            .navigationTitle("general.more")
        } content: {
            Group {
                if let destination = viewModel.currentPage {
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
        } detail: {
            navigationDetailView
        }
    }
}
