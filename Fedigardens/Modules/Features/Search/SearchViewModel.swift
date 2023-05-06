//
//  SearchViewModel.swift
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
import Combine
import Foundation

class SearchViewModel: ObservableObject {
    @Published var searchableText = ""
    @Published var searchResult: SearchResult?
    @Published var directory = [Account]()
    @Published var trendingStatuses = [Status]()

    @Published var currentPresentedAccount: Account?

    func clearSearchResults() {
        searchableText = ""
        searchResult = nil
    }

    func requestSearchResults() async {
        let response: Alice.Response<SearchResult> = await Alice.shared.get(.search, params: params())
        switch response {
        case .success(let result):
            DispatchQueue.main.async {
                self.searchResult = result
            }
        case .failure(let error):
            print("Search error: \(error.localizedDescription)")
        }
    }

    func fetchDirectory() async {
        let response: Alice.Response<[Account]> = await Alice.shared.get(
            .directory,
            params: ["order": "active", "limit": "10"]
        )
        switch response {
        case .success(let result):
            DispatchQueue.main.async {
                self.directory = result
            }
        case .failure(let error):
            print("Directory error: \(error.localizedDescription)")
        }
    }

    func fetchTrendingStatuses() async {
        let response: Alice.Response<[Status]> = await Alice.shared.get(.trendingStatuses)
        switch response {
        case .success(let trending):
            DispatchQueue.main.async {
                self.trendingStatuses = trending
            }
        case .failure(let error):
            print("Fetch statuses error: \(error.localizedDescription)")
        }
    }

    private func params() -> [String: String] {
        ["q": searchableText]
    }
}
