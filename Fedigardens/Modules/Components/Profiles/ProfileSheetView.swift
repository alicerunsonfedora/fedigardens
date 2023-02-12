//
//  ProfileSheetView.swift
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

import SwiftUI
import Alice
import EmojiText

struct ProfileSheetView: View {
    @Environment(\.customEmojis) var emojis
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ProfileSheetViewModel()
    var profile: Account

    private var allEmojis: [any CustomEmoji] {
        emojis + profile.emojis.map { emoji in emoji.remote() }
    }

    var body: some View {
        NavigationStack {
            List {
                ProfileSheetHeaderView(profile: profile)
                    .environmentObject(viewModel)
                ProfileSheetRecentActivityView()
                    .environmentObject(viewModel)
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ProfileSheetToolbar(viewModel: viewModel)
            }
        }
        .animation(.spring(), value: viewModel.layoutState)
        .onAppear {
            Task {
                viewModel.profile = profile
                await viewModel.fetchStatuses()
                await viewModel.fetchRelationships()
            }
        }
    }
}

struct ProfileSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileSheetView(profile: MockData.profile!)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
