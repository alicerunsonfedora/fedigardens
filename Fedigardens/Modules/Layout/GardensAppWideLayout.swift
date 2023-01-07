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
                NavigationLink(value: GardensAppPage.forYou) {
                    Label("endpoint.home", systemImage: "house")
                }
                NavigationLink(value: GardensAppPage.local) {
                    Label("endpoint.local", systemImage: "building.2")
                }
                NavigationLink(value: GardensAppPage.public) {
                    Label("endpoint.latest", systemImage: "sparkles")
                }
                NavigationLink(value: GardensAppPage.messages) {
                    Label("endpoint.directmessage", systemImage: "bubble.left.and.bubble.right")
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
                            .navigationTitle("endpoint.home")
                    case .local:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .network, local: true),
                            selectedStatus: $viewModel.selectedStatus
                        )
                            .navigationTitle("endpoint.local")
                    case .public:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .network, local: false),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationTitle("endpoint.latest")
                    case .messages:
                        MessagingList()
                            .navigationTitle("endpoint.directmessage")
                    case .saved:
                        TimelineSplitView(scope: .saved, selectedStatus: $viewModel.selectedStatus)
                            .navigationTitle("endpoint.saved")
                    case .selfPosts:
                        TimelineSplitView(
                            scope: .profile(id: userProfile.id),
                            selectedStatus: $viewModel.selectedStatus
                        )
                        .navigationTitle("endpoint.selfposts")
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
