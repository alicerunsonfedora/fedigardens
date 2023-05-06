//
//  ProfileSheetRecentActivityView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/15/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import SwiftUI

struct ProfileSheetRecentActivityView: View {
    @EnvironmentObject var viewModel: ProfileSheetViewModel

    var body: some View {
        Group {
            switch viewModel.layoutState {
            case .initial, .loading:
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            case .loaded:
                Section {
                    ForEach(viewModel.statuses, id: \.uuid) { status in
                        StatusView(status: status)
                            .lineLimit(3)
                            .profilePlacement(.hidden)
                            .datePlacement(.automatic)
                    }
                } header: {
                    Text("profile.activity")
                }
            case .errored(let message):
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundColor(.secondary)
                        Text(message)
                            .font(.headline)
                    }
                    Spacer()
                }.listRowBackground(Color.clear)
            }
        }
    }
}
