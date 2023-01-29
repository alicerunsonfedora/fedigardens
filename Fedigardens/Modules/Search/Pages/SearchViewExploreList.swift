//
//  SearchViewExploreList.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/28/23.
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

struct SearchViewExploreList: View {
    @StateObject var viewModel: SearchViewModel
    var body: some View {
        List {
            Group {
                if viewModel.directory.isNotEmpty {
                    Section {
                        SearchDirectoryView(directory: viewModel.directory, viewModel: viewModel)
                    } header: {
                        Text("search.directory")
                    }
                    .headerProminence(.increased)
                    .listRowSeparator(.hidden)
                }
            }

            Group {
                if viewModel.trendingStatuses.isNotEmpty {
                    Section {
                        ForEach(viewModel.trendingStatuses, id: \.uuid) { status in
                            NavigationLink(value: status) {
                                StatusView(status: status)
                                    .lineLimit(2)
                                    .profilePlacement(.hidden)
                                    .datePlacement(.automatic)
                                    .profileImageSize(44)
                                    .verifiedNoticePlacement(.byAuthorName)
                                    .tint(.secondary)
                            }
                        }
                    } header: {
                        Text("search.explore")
                    }
                    .headerProminence(.increased)
                    .listRowSeparator(.hidden)
                }
            }

        }
        .listStyle(.inset)
        .navigationDestination(for: Status.self) { status in
            StatusDetailView(status: status, level: .parent)
        }
    }
}
