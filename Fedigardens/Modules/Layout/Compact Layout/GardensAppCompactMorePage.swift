//
//  GardensAppCompactMorePage.swift
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

import Alice
import Bunker
import SwiftUI

struct GardensAppCompactMorePage<Detail: View>: View {
    @Environment(\.userProfile) var userProfile
    @StateObject var viewModel: GardensAppLayoutViewModel
    @Binding var currentPage: GardensAppPage?

    var sharedDetail: () -> Detail

    var body: some View {
        NavigationSplitView {
            List(selection: $currentPage) {
                Group {
                    GardensPageLink(page: .public)
                    GardensPageLink(page: .messages)
                    GardensPageLink(page: .selfPosts)
                    GardensPageLink(page: .saved)
                    GardensPageLink(page: .settings)
                }
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

                if viewModel.tags.isNotEmpty {
                    GardensAppSubscribedTagsDestination(viewModel: viewModel)
                }

                if viewModel.tags.isNotEmpty {
                    GardensAppTrendingTagsDestination(viewModel: viewModel)
                }
            }
            .navigationTitle("general.more")
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
                EditButton()
            }
        } content: {
            GardensAppCompactSidebarContent(viewModel: viewModel, currentPage: $currentPage)
        } detail: {
            sharedDetail()
        }
    }
}
