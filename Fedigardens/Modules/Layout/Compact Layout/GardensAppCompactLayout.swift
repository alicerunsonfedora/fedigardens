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
    typealias TimelineType = TimelineSplitViewModel.TimelineType

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
            GardensAppCompactMorePage(viewModel: viewModel) {
                navigationDetailView
            }
                .tabItem { Label("general.more", systemImage: "ellipsis.circle") }
        }
        .onAppear {
            loadSidebar()
        }
        .refreshable {
            loadSidebar()
        }
        .animation(.spring(), value: viewModel.subscribedTags)
        .animation(.spring(), value: viewModel.tags)
        .animation(.spring(), value: viewModel.lists)
        .alert("followedtags.alert.title", isPresented: $viewModel.shouldShowSubscriptionAlert) {
            TextField("followedtags.textfield.placeholder", text: $viewModel.subscribedTagRequestedText)
            Button {
                Task { await viewModel.subscribeToCurrentTag() }
            } label: {
                Text("followedtags.subscribeaction")
            }
            Button(role: .cancel) {
                viewModel.shouldShowSubscriptionAlert.toggle()
            } label: {
                Text("general.cancel")
            }
        } message: {
            Text("followedtags.alert.detail")
        }
    }

    private func loadSidebar() {
        viewModel.currentPage = nil
        Task { await viewModel.fetchTags() }
        Task { await viewModel.fetchSubscriptions() }
        Task { await viewModel.fetchLists() }
    }

    private func rootTab(for scope: TimelineType, page: GardensAppPage) -> some View {
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
}
