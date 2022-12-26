//
//  TimelineSplitViewModel.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import Combine
import Chica

class TimelineSplitViewModel: ObservableObject {
    enum TimelineType {
        case scopedTimeline(scope: TimelineScope, local: Bool)
        case profile(id: String)
    }

    enum TimelineReloadPolicy {
        case refreshEntireContents
        case preloadNextBatch
    }

    @Published var timelineData: [Status]? = []
    @Published var dummyTimeline: [Status]? = MockData.timeline
    @Published var state: LayoutState = .initial
    @Published var scope: TimelineType = .scopedTimeline(scope: .home, local: false)

    init(scope: TimelineType) {
        self.scope = scope
    }

    /// Load the timeline into the view.
    /// - Parameter forcefully: Whether to forcefully reload the data, regardless if the timeline is already loaded.
    ///     Defaults to false.
    ///
    /// Typically, this method is called when rendering the view for the first time to fetch the timeline contents.
    /// Since the network call is asynchronous, this method has been made asynchronous.
    ///
    /// - Important: Only forcefully reload data when the user requests it. This call may be expensive on the network
    ///     and may take time to re-fetch the data into memory.
    func loadTimeline(
        forcefully userInitiated: Bool = false,
        policy: TimelineReloadPolicy
    ) async -> LayoutState {
        if !userInitiated, timelineData?.isEmpty == false {
            return .loaded
        }
        do {
            switch scope {
            case .scopedTimeline(let scope, let localScoped):
                let statuses: [Status]? = try await Chica.shared.request(
                    .get,
                    for: .timeline(scope: scope),
                    params: createRequestParameters(locally: localScoped, using: policy)
                )
                insertStatuses(statuses: statuses, with: policy)
            case .profile(let id):
                let statuses: [Status]? = try await Chica.shared.request(
                    .get,
                    for: .accountStatuses(id: id),
                    params: createRequestParameters(using: policy)
                )
                insertStatuses(statuses: statuses, with: policy)
            }
            return .loaded
        } catch {
            print(error)
            return .errored(message: error.localizedDescription)
        }
    }

    private func insertStatuses(statuses: [Status]?, with policy: TimelineReloadPolicy) {
        DispatchQueue.main.async {
            if let previous = self.timelineData, !previous.isEmpty, policy == .preloadNextBatch {
                self.timelineData = previous + (statuses ?? [])
            } else {
                self.timelineData = statuses
            }
        }
    }

    private func createRequestParameters(
        locally local: Bool = false,
        using policy: TimelineReloadPolicy
    ) -> [String: String] {
        var parameters = ["limit": String(UserDefaults.standard.loadLimit)]
        if local { parameters["local"] = "true" }
        if case .scopedTimeline = scope, policy == .preloadNextBatch, let lastPost = timelineData?.last {
            parameters["max_id"] = lastPost.id
        }
        return parameters
    }
}
