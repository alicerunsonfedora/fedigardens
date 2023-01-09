//
//  StatusContextProvider.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/26/22.
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

struct StatusContextProvider: View {
    enum ContextDisplayMode {
        case ancestors
        case descendants
    }
    @ObservedObject var viewModel: StatusDetailViewModel
    var context: Context
    var displayMode: ContextDisplayMode = .descendants

    var statuses: [Status]? {
        switch displayMode {
        case .descendants:
            return context.descendants
        case .ancestors:
            return context.ancestors
        }
    }

    var body: some View {
        Section {
            if let replies = statuses, !replies.isEmpty {
                ForEach(replies, id: \.uuid) { reply in
                    contextLink(for: reply)
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private func contextLink(for reply: Status) -> some View {
        NavigationLink(value: viewModel.contextCaller(for: reply)) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "text.bubble")
                    .imageScale(.large)
                StatusView(status: reply)
                    .profilePlacement(.byAuthorName)
                    .profileImageSize(32)
                    .datePlacement(.underContent)
            }
            .listRowInsets(.init(top: 8, leading: 32, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden, edges: .all)
        }
    }
}
