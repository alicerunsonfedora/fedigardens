//
//  SearchView.swift
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

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Binding var selectedStatus: Status?

    var body: some View {
        Group {
            if let results = viewModel.searchResult {
                SearchResultsView(viewModel: viewModel, results: results)
            } else {
                SearchViewExploreList(viewModel: viewModel)
            }
        }
        .navigationTitle("endpoint.search")
        .searchable(text: $viewModel.searchableText, prompt: Text("search.placeholder"))
        .animation(.spring(), value: viewModel.directory)
        .animation(.spring(), value: viewModel.trendingStatuses)
        .animation(.spring(), value: viewModel.searchResult)
        .onSubmit(of: .search) {
            Task {
                await viewModel.requestSearchResults()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchDirectory()
                await viewModel.fetchTrendingStatuses()
            }
        }
        .refreshable {
            Task {
                await viewModel.fetchDirectory()
                await viewModel.fetchTrendingStatuses()
            }
        }
        .sheet(item: $viewModel.currentPresentedAccount) { account in
            ProfileSheetView(profile: account)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationStack {
                SearchView(selectedStatus: .constant(nil))
            }
            .tabItem {
                Label("general.search", systemImage: "magnifyingglass")
            }
        }

    }
}
