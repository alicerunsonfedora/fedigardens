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

import SwiftUI
import Alice
import EmojiText

struct ProfileSheetHeaderView: View {
    @EnvironmentObject var viewModel: ProfileSheetViewModel
    @Environment(\.customEmojis) var emojis
    var profile: Account

    private var allEmojis: [any CustomEmoji] {
        emojis + profile.emojis.map { emoji in emoji.remote() }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    AccountImage(author: profile)
                        .profileSize(.xxlarge)
                    EmojiText(markdown: profile.getAccountName(), emojis: allEmojis)
                        .font(.system(.largeTitle, design: .rounded))
                        .multilineTextAlignment(.center)
                        .bold()
                    Text("@\(profile.acct)")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    if viewModel.relationship?.followedBy == true {
                        Text("profile.followsyou")
                            .textCase(.uppercase)
                            .font(.system(.footnote, design: .rounded))
                            .bold()
                            .padding(.horizontal, 6)
                            .foregroundColor(.secondary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder()
                                    .foregroundColor(.secondary)
                            }
                    }
                }
                Spacer()
            }
            HStack {
                ProfileSheetStatisticCellView(
                    key: "profile.followers",
                    value: "\(profile.followersCount)",
                    systemName: "person.2.fill"
                )
                ProfileSheetStatisticCellView(
                    key: "profile.following",
                    value: "\(profile.followingCount)",
                    systemName: "person.3.fill"
                )
                ProfileSheetStatisticCellView(
                    key: "profile.statusescount",
                    value: "\(profile.statusesCount)",
                    systemName: "square.and.pencil"
                )
            }
            EmojiText(markdown: profile.note.markdown(), emojis: allEmojis)
                .font(.subheadline)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 2, leading: 0, bottom: 2, trailing: 0))

        Section {
            ForEach(profile.fields) { field in
                LabeledContent(field.name) {
                    Text(field.value.attributedHTML())
                }
                .listRowBackground(
                    field.value == profile.verifiedDomain()
                    ? Color.green.opacity(0.2)
                    : Color(uiColor: .secondarySystemGroupedBackground)
                )
                .tint(
                    field.value == profile.verifiedDomain()
                    ? Color.green
                    : Color.accentColor
                )
            }
        }
    }
}
