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
            rootTab(for: .scopedTimeline(scope: .home, local: false), named: "endpoint.home", systemImage: "house")
            rootTab(
                for: .scopedTimeline(scope: .network, local: true),
                named: "endpoint.local",
                systemImage: "building.2"
            )
            NavigationStack {
                MessagingList()
                    .navigationTitle("endpoint.directmessage")
            }
            .tabItem {
                Label("endpoint.directmessage", systemImage: "bubble.left.and.bubble.right")
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
        named name: LocalizedStringKey,
        systemImage: String
    ) -> some View {
        NavigationSplitView {
            TimelineSplitView(scope: scope, selectedStatus: $viewModel.selectedStatus)
            .listStyle(.inset)
            .navigationTitle(name)
            .toolbar {
                ToolbarItem {
                    GardensComposeButton(style: .new)
                }
            }
        } detail: {
            navigationDetailView
        }
        .tabItem {
            Label(name, systemImage: systemImage)
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
                NavigationLink(value: GardensAppPage.public) {
                    Label("endpoint.latest", systemImage: "sparkles")
                }
                NavigationLink(value: GardensAppPage.selfPosts) {
                    Label("endpoint.selfposts", systemImage: "person.circle")

                }
                NavigationLink(value: GardensAppPage.saved) {
                    Label("endpoint.saved", systemImage: "bookmark")
                }
                NavigationLink(value: GardensAppPage.settings) {
                    Label("general.settings", systemImage: "gear")
                }

                if !viewModel.lists.isEmpty {
                    Section {
                        ForEach(viewModel.lists) { list in
                            NavigationLink(value: GardensAppPage.list(id: list.id)) {
                                Label(list.title, systemImage: "folder")
                            }
                        }
                    } header: {
                        Text("endpoint.lists")
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
                        Text("endpoint.trending")
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
