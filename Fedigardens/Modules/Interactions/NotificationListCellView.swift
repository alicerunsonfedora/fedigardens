//
//  NotificationListCellView.swift
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

import SwiftUI
import Alice
import class Alice.Notification

struct NotificationListCellView: View {
    var notification: Notification

    var body: some View {
        VStack(alignment: .trailing) {
            if let reply = notification.status {
                Group {
                    StatusView(status: reply)
                        .lineLimit(2)
                        .profilePlacement(.hidden)
                        .datePlacement(.automatic)
                        .profileImageSize(44)
                        .verifiedNoticePlacement(.byAuthorName)
                        .tint(.secondary)
                    StatusQuickGlanceView(status: reply)
                }
            }

        }
    }
}
