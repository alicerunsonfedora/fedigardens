//
//  StatusNavigationListViewModel.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/25/22.
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

class StatusNavigationListViewModel: ObservableObject {
    @Published var statuses: [Status]

    init(statuses: [Status]) {
        self.statuses = statuses
    }

    init() {
        self.statuses = []
    }

    func insert(statuses: [Status]) {
        self.statuses.append(contentsOf: statuses)
    }

    func toggleFavorite(status: Status) async {
        await update(status: status) { changed in
            try await Chica.shared.request(
                .post, for: changed.favourited == true ? .unfavorite(id: changed.id) : .favourite(id: changed.id)
            )
        }
    }

    /// Make a request to update the current status.
    /// - Parameter means: A closure that will be performed to update the status. Should return an optional status,
    ///     which represents the newly modified status.
    private func update(status: Status, by means: (Status) async throws -> Status?) async {
        var updated: Status?

        do {
            updated = try await means(status)
        } catch {
            print("Error occured when updating status: \(error.localizedDescription)")
            return
        }

        if let new = updated {
            DispatchQueue.main.async { [self] in
                replaceInList(status: new)
            }
        }
    }

    private func replaceInList(status: Status) {
        if let firstIdx = statuses.firstIndex(where: { $0.id == status.id }) {
            statuses[firstIdx] = status
        }
    }
}
