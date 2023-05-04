//
//  SearchAccountView.swift
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

struct SearchAccountView: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode
    var account: Account

    private var emojis: [RemoteEmoji] {
        return (enforcedFrugalMode || frugalMode) ? [] : account.emojis.map(\.remoteEmoji)
    }

    var body: some View {
        HStack {
            AccountImage(author: account)
                .profileSize(.large)
            VStack(alignment: .leading) {
                HStack {
                    EmojiText(
                        markdown: account.getAccountName(),
                        emojis: emojis
                    )
                    .font(.headline)
                    Text("@\(account.acct)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .lineLimit(1)

                EmojiText(markdown: account.note.markdown(), emojis: emojis)
                    .lineLimit(2)
                    .font(.footnote)
            }
        }
        .tint(.secondary)
    }
}

struct SearchAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                ForEach(0..<9) { _ in
                    SearchAccountView(account: MockData.profile!)
                }
            }
        }
    }
}
