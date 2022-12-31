//
//  FedigardensAppLayoutViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/29/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Combine
import Alice

class GardensAppLayoutViewModel: ObservableObject {
    typealias PageSelection = GardensAppLayout.PageSelection
    @Published var dummyTimeline: [Status] = MockData.timeline!
    @Published var currentPage: PageSelection? = .forYou
    @Published var selectedStatus: Status?
    @Published var tags: [Tag] = []
    @Published var lists: [MastodonList] = []

    init() {}

    func fetchTags() async {
        let response: Alice.Response<[Tag]> = await Alice.shared.request(.get, for: .trending)
        switch response {
        case .success(let tags):
            DispatchQueue.main.async { self.tags = tags }
        case .failure(let error):
            print("Tag fetch error: \(error.localizedDescription)")
        }
    }

    func fetchLists() async {
        let response: Alice.Response<[MastodonList]> = await Alice.shared.request(.get, for: .lists)
        switch response {
        case .success(let lists):
            DispatchQueue.main.async { self.lists = lists }
        case .failure(let error):
            print("List fetch error: \(error.localizedDescription)")
        }
    }

}
