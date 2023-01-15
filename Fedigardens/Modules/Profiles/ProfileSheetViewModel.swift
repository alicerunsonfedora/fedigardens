//
//  ProfileSheetViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/14/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Combine
import Alice
import Drops
import UIKit

class ProfileSheetViewModel: ObservableObject {
    @Published var profile: Account?
    @Published var statuses = [Status]()
    @Published var layoutState = LayoutState.initial
    @Published var relationship: Relationship?

    func fetchStatuses() async {
        guard let profile else { return }
        await fetch(method: .get, for: .accountStatuses(id: profile.id), as: [Status].self) { statuses in
            self.statuses = statuses
        }
    }

    func fetchRelationships() async {
        guard let profile else { return }
        await fetch(
            method: .get,
            for: .generalRelationships,
            with: ["id[]": profile.id],
            as: [Relationship].self
        ) { relationships in
            self.relationship = relationships.first
        }
    }

    func toggleFollow() async {
        await updateRelationship(
            drop: Drop(
                title: relationship?.following == true ? "drop.unfollow" : "drop.follow",
                icon: UIImage(
                    systemName: relationship?.following == true ? "person.badge.minus" : "person.badge.plus"
                )
            )
        ) { account in
            return await Alice.shared.request(.post, for: .followAccount(id: account.id))
        }
    }

    func toggleMute() async {
        await updateRelationship(
            drop: Drop(
                title: relationship?.muting == true ? "drop.unmute" : "drop.mute",
                icon: UIImage(
                    systemName: relationship?.muting == true
                        ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.moon.fill"
                )
            )
        ) { account in
            return await Alice.shared.request(
                .post, for: relationship?.muting == true ? .unmuteAccount(id: account.id) : .muteAccount(id: account.id)
            )
        }
    }

    private func updateRelationship(
        drop: Drop? = nil,
        by means: (Account) async -> Alice.Response<Relationship>
    ) async {
        guard let profile else { return }
        let response = await means(profile)
        switch response {
        case .success(let newRelationship):
            DispatchQueue.main.async {
                self.relationship = newRelationship
                if let drop {
                    Drops.show(drop)
                }
            }
        case .failure(let error):
            print("Update failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                Drops.show(
                    .init(
                        title: "drop.profilefailure".localized(comment: "Couldn't update profile"),
                        subtitle: error.localizedDescription,
                        icon: UIImage(systemName: "xmark.circle")
                    )
                )
            }
        }
    }

    private func fetch<T: Decodable>(
        method: Alice.Method,
        for endpoint: Endpoint,
        with parameters: [String: String]? = nil,
        as type: T.Type,
        completion: @escaping (T) -> Void
    ) async {
        DispatchQueue.main.async {
            self.layoutState = .loading
        }
        let response: Alice.Response<T> = await Alice.shared.request(method, for: endpoint, params: parameters)
        switch response {
        case .success(let data):
            DispatchQueue.main.async {
                completion(data)
                self.layoutState = .loaded
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.layoutState = .errored(message: error.localizedDescription)
            }
            print("Fetch error: \(error.localizedDescription)")
        }
    }
}
