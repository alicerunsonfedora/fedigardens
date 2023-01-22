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
                GardensAppWideCommonDestinationsGroup()
                if viewModel.lists.isNotEmpty {
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

                if viewModel.subscribedTags.isNotEmpty {
                    GardensAppSubscribedTagsDestination(viewModel: viewModel)
                }

                if viewModel.tags.isNotEmpty {
                    GardensAppTrendingTagsDestination(viewModel: viewModel)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("general.appname")
            .toolbar {
                Menu {
                    Button {
                        viewModel.shouldShowSubscriptionAlert.toggle()
                    } label: {
                        Label("sidebar.followedtags.action", systemImage: "dot.radiowaves.up.forward")
                    }
                } label: {
                    Label("Add", systemImage: "plus.circle")
                }
            }
        } content: {
            GardensAppSidebarContent(viewModel: viewModel)
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
            loadSidebar()
        }
        .refreshable {
            loadSidebar()
        }
        .animation(.spring(), value: viewModel.subscribedTags)
        .animation(.spring(), value: viewModel.tags)
        .animation(.spring(), value: viewModel.lists)
        .sheet(isPresented: $shouldDisplayComposeModal) {
            Text("Hi")
        }
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
        Task { await viewModel.fetchSubscriptions() }
        Task { await viewModel.fetchTags() }
        Task { await viewModel.fetchLists() }
    }
}

// MARK: - Previews

struct WidescreenLayout_Previews: PreviewProvider {
    static var previews: some View {
        GardensAppWideLayout()
            .frame(minWidth: 900, minHeight: 500)
    }
}
