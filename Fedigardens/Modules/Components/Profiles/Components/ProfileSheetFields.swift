//
//  ProfileSheetFields.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/28/23.
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

struct ProfileSheetFields: View {
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    var profile: Account

    private var emojis: [RemoteEmoji] {
        return (enforcedFrugalMode || frugalMode) ? [] : profile.emojis.map(\.remoteEmoji)
    }

    var body: some View {
        Group {
            ForEach(profile.fields) { (field: Field) in
                LabeledContent(field.name) {
                    EmojiText(markdown: field.value.markdown(), emojis: emojis)
                        .multilineTextAlignment(.trailing)
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
