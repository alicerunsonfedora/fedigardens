//
//  TimelineSplitViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import UIKit
import Combine
import Alice

class TimelineSplitViewModel: ObservableObject {
    enum TimelineType: Equatable {
        case scopedTimeline(scope: TimelineScope, local: Bool)
        case profile(id: String)
        case saved

        static func == (lhs: TimelineSplitViewModel.TimelineType, rhs: TimelineSplitViewModel.TimelineType) -> Bool {
            return String(describing: lhs) == String(describing: rhs)
        }
    }

    enum ReloadPolicy {
        case refreshEntireContents
        case preloadNextBatch
    }

    @Published var timelineData: [Status] = []
    @Published var dummyTimeline: [Status] = MockData.timeline!
    @Published var state: LayoutState = .initial
    @Published var scope: TimelineType = .scopedTimeline(scope: .home, local: false)
    @Published var interventionTimeout: Date?
    @Published var displayOneSecNotInstalledWarning = false

    init(scope: TimelineType) {
        self.scope = scope
    }

    /// Load the timeline into the view.
    /// - Parameter forcefully: Whether to forcefully reload the data, regardless if the timeline is already
    /// loaded. Defaults to false.
    ///
    /// Typically, this method is called when rendering the view for the first time to fetch the timeline
    /// contents. Since the network call is asynchronous, this method has been made asynchronous.
    ///
    /// - Important: Only forcefully reload data when the user requests it. This call may be expensive on the
    /// network and may take time to re-fetch the data into memory.
    func loadTimeline(
        forcefully userInitiated: Bool = false,
        policy: ReloadPolicy,
        intervening timeout: TimeInterval? = nil,
        using handler: InterventionHandler? = nil
    ) async -> LayoutState {
        if !userInitiated, timelineData.isEmpty == false {
            return .loaded
        }
        let expectedMechanism: InterventionAllowedMechanisms = policy == .refreshEntireContents ? .refresh : .fetchMore
        if userInitiated, let handler, handler.allowedMechanisms.contains(expectedMechanism) {
            let eventualState = await handler.startIntervention {
                DispatchQueue.main.async {
                    self.displayOneSecNotInstalledWarning.toggle()
                }
            }
            return eventualState
        }

        var callInLocalScope = false
        if case .scopedTimeline(_, let local) = scope { callInLocalScope = local }

        let response = await callAlice(local: callInLocalScope, policy: policy)
        switch response {
        case .success(let statuses):
            insertStatuses(statuses: statuses, with: policy)
            return .loaded
        case .failure(let error):
            print("Failed to load timeline: \(error)")
            return .errored(message: error.localizedDescription)
        }
    }

    private func callAlice(local: Bool, policy: ReloadPolicy) async -> Alice.Response<[Status]> {
        return await Alice.shared.request(
            .get,
            for: endpoint(),
            params: requestParams(locally: local, using: policy)
        )
    }

    private func endpoint() -> Endpoint {
        switch scope {
        case .profile(let id):
            return .accountStatuses(id: id)
        case .scopedTimeline(let scope, _):
            return .timeline(scope: scope)
        case .saved:
            return .bookmarks
        }
    }

    private func insertStatuses(statuses: [Status], with policy: ReloadPolicy) {
        DispatchQueue.main.async {
            if !self.timelineData.isEmpty, policy == .preloadNextBatch {
                self.timelineData.append(contentsOf: statuses)
            } else {
                self.timelineData = statuses
            }
        }
    }

    private func requestParams(locally local: Bool = false, using policy: ReloadPolicy) -> [String: String] {
        var parameters = ["limit": String(UserDefaults.standard.loadLimit)]
        if local { parameters["local"] = "true" }
        if case .scopedTimeline = scope, policy == .preloadNextBatch, let lastPost = timelineData.last {
            parameters["max_id"] = lastPost.id
        }
        return parameters
    }
}
