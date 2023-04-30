//
//  ProfileSheetLabel.swift
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

struct ProfileSheetLabel: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    var profile: Account

    private var emojis: [RemoteEmoji] {
        return frugalMode ? [] : profile.emojis.map(\.remoteEmoji)
    }

    var body: some View {
        VStack(spacing: 4) {
            AccountImage(author: profile)
                .profileSize(.xxlarge)
            EmojiText(markdown: profile.getAccountName(), emojis: emojis)
                .font(.system(.largeTitle, design: .rounded))
                .multilineTextAlignment(.center)
                .bold()
            Text("@\(profile.acct)")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}
