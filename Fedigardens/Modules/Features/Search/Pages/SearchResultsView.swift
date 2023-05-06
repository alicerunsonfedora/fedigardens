//
//  SearchResultsView.swift
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

import Alice
import Bunker
import SwiftUI

struct SearchResultsView: View {
    @Environment(\.isSearching) private var isSearching
    @StateObject var viewModel: SearchViewModel

    enum Filter: String, Hashable, CaseIterable {
        case all = "search.filter.all"
        case people = "search.filter.users"
        case statuses = "search.filter.posts"
        case tags = "search.filter.tags"
    }

    var results: SearchResult
    @State private var filter: Filter = .all

    var body: some View {
        List {
            Section {
                HStack {
                    ForEach(Filter.allCases, id: \.hashValue) { filterCase in
                        Button {
                            withAnimation {
                                self.filter = filterCase
                            }
                        } label: {
                            Text(filterCase.rawValue.localized())
                        }
                        .tint(filter == filterCase ? .accentColor : .secondary)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .lineLimit(1)
                }
            }
            .listRowSeparator(.hidden)
            .animation(.spring(), value: filter)
            Group {
                if let accounts = results.accounts, accounts.isNotEmpty, filterAccepts(.people) {
                    Section {
                        ForEach(accounts, id: \.id) { account in
                            Button {
                                viewModel.currentPresentedAccount = account
                            } label: {
                                SearchAccountView(account: account)
                            }
                        }
                    } header: {
                        Text("search.filter.users")
                    }
                    .headerProminence(.increased)
                    .listRowSeparator(.hidden)
                }
            }
            Group {
                if let statuses = results.statuses, statuses.isNotEmpty, filterAccepts(.statuses) {
                    Section {
                        ForEach(statuses, id: \.id) { status in
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
                        Text("search.filter.posts")
                    }
                    .headerProminence(.increased)
                    .listRowSeparator(.hidden)
                }
            }

            Group {
                if let tags = results.hashtags, tags.isNotEmpty, filterAccepts(.tags) {
                    Section {
                        ForEach(tags, id: \.name) { tag in
                            NavigationLink(value: tag) {
                                SearchTagView(tag: tag)
                            }
                        }
                    } header: {
                        Text("search.filter.tags")
                    }
                    .headerProminence(.increased)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.inset)
        .onChange(of: isSearching) { newValue in
            if !newValue { viewModel.clearSearchResults() }
        }
    }

    private func filterAccepts(_ requestedFilter: Filter) -> Bool {
        return filter == .all || filter == requestedFilter
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchResultsView(
                viewModel: .init(),
                results: MockData.searchResults!
            )
            .navigationDestination(for: Tag.self) { tag in
                SearchTagResultPage(tag: tag)
            }
        }
    }
}
