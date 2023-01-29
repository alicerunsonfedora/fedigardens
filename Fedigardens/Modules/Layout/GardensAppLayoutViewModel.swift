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
    @Published var dummyTimeline: [Status] = MockData.timeline!
    @Published var currentPage: GardensAppPage? = .forYou
    @Published var selectedStatus: Status?
    @Published var subscribedTags: [Tag] = []
    @Published var tags: [Tag] = []
    @Published var lists: [MastodonList] = []
    @Published var shouldShowSubscriptionAlert = false
    @Published var subscribedTagRequestedText = ""

    init() {}

    func fetchTags() async {
        let response: Alice.Response<[Tag]> = await Alice.shared.get(.trending)
        switch response {
        case .success(let tags):
            DispatchQueue.main.async { self.tags = tags }
        case .failure(let error):
            print("Tag fetch error: \(error.localizedDescription)")
        }
    }

    func fetchSubscriptions() async {
        let response: Alice.Response<[Tag]> = await Alice.shared.get(.followedTags)
        switch response {
        case .success(let subscriptions):
            DispatchQueue.main.async { self.subscribedTags = subscriptions }
        case .failure(let error):
            print("Followed tag fetch error: \(error.localizedDescription)")
        }
    }

    func fetchLists() async {
        let response: Alice.Response<[MastodonList]> = await Alice.shared.get(.lists)
        switch response {
        case .success(let lists):
            DispatchQueue.main.async { self.lists = lists }
        case .failure(let error):
            print("List fetch error: \(error.localizedDescription)")
        }
    }

    func subscribeToCurrentTag() async {
        let response: Alice.Response<Tag> = await Alice.shared.post(.followTag(id: subscribedTagRequestedText))
        switch response {
        case .success(let newTag):
            DispatchQueue.main.async {
                self.subscribedTags.append(newTag)
                self.subscribedTagRequestedText = ""
            }
        case .failure(let error):
            print("Follow tag error: \(error.localizedDescription)")
        }
    }

    func deleteSubscribedTags(at offsets: IndexSet) {
        offsets.forEach { offset in
            let tag = subscribedTags.remove(at: offset)
            Task {
                await self.unsubscribeToTag(named: tag.name)
            }
        }
    }

    private func unsubscribeToTag(named name: String) async {
        let response: Alice.Response<EmptyNode> = await Alice.shared.post(.unfollowTag(id: name))
        switch response {
        case .success:
            break
        case .failure(let error):
            print("Unfollow tag error: \(error.localizedDescription)")
        }
    }

}
