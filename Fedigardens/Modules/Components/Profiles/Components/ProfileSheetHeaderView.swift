//
//  ProfileSheetHeaderView.swift
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
import EmojiText
import SeedUI
import SwiftUI

struct ProfileSheetHeaderView: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    @EnvironmentObject var viewModel: ProfileSheetViewModel
    @Environment(\.customEmojis) var emojis
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode
    var profile: Account

    private var allEmojis: [RemoteEmoji] {
        if enforcedFrugalMode || frugalMode { return [] }
        return emojis + profile.emojis.map(\.remoteEmoji)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    ProfileSheetLabel(profile: profile)
                    if viewModel.relationship?.followedBy == true {
                        BadgedText("profile.followsyou")
                            .badgeColor(.secondary)
                            .font(.system(.footnote, design: .rounded))
                    }
                }
                Spacer()
            }
            ProfileSheetStatistics(profile: profile)
            EmojiText(markdown: profile.note.markdown(), emojis: allEmojis)
                .font(.subheadline)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 2, leading: 0, bottom: 2, trailing: 0))

        Section {
            ProfileSheetFields(profile: profile)
        }
    }
}
