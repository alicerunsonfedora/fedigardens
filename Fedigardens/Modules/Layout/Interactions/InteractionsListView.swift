//
//  NotificationsListView.swift
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

struct InteractionsListView: View {
    @Binding var selectedStatus: Status?
    @StateObject private var viewModel = InteractionsListViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .initial:
                Image(systemName: "bell")
                    .foregroundColor(.secondary)
                    .font(.largeTitle)
            case .loading:
                ProgressView()
                    .font(.largeTitle)
            case .loaded:
                List(selection: $selectedStatus) {
                    ForEach(viewModel.notifications, id: \.uuid) { mention in
                        if let response = mention.status {
                            NavigationLink(value: response) {
                                NotificationListCellView(notification: mention)
                            }
                        } else {
                            Text("WTF?!: \(mention.type.rawValue)")
                        }

                    }
                }
            case .errored(let message):
                Text(message)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchNotifications()
            }
        }
    }
}
