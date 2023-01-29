//
//  SearchTagViewModel.swift
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

import Foundation
import Combine
import Alice

class SearchTagViewModel: ObservableObject {
    @Published var tag: Tag?
    @Published var timeline = [Status]()

    func fetchTimeline() async {
        guard let tag else { return }
        let scope: TimelineScope = .tag(tag: tag.name)
        let response: Alice.Response<[Status]> = await Alice.shared.request(.get, for: .timeline(scope: scope))
        switch response {
        case .success(let statuses):
            DispatchQueue.main.async {
                self.timeline = statuses
            }
        case .failure(let error):
            print("Failed to get timeline: \(error.localizedDescription)")
        }
    }

    func subscribeToTag() async {
        guard let tag else { return }
        let response: Alice.Response<Tag> = await Alice.shared.request(.post, for: .followTag(id: tag.name))
        switch response {
        case .success(let newTag):
            DispatchQueue.main.async {
                self.tag = newTag
            }
        case .failure(let error):
            print("Follow tag error: \(error.localizedDescription)")
        }
    }
}
