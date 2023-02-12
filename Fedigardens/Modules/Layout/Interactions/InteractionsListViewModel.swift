//
//  NotificationsListViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/7/23.
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
import struct Alice.Notification

class InteractionsListViewModel: ObservableObject {
    @Published var notifications = [Notification]()
    @Published var state = LayoutState.initial

    init() {}

    func fetchNotifications() async {
        DispatchQueue.main.async { self.state = .loading }
        let response: Alice.Response<[Notification]> = await Alice.shared.get(
            .notifications,
            params: [
                "types[]": Notification.NotificationType.mention.rawValue,
                "limit": String(UserDefaults.standard.loadLimit)
            ]
        )
        switch response {
        case .success(let notificationList):
            DispatchQueue.main.async {
                self.notifications.append(contentsOf: notificationList)
                self.state = .loaded
            }
        case .failure(let error):
            print("Notification fetch failure: \(error.localizedDescription)")
            DispatchQueue.main.async { self.state = .errored(message: error.localizedDescription) }
        }
    }
}
