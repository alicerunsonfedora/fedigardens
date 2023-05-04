//
//  SearchDirectoryView.swift
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

struct SearchDirectoryView: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode
    var directory: [Account]
    @StateObject var viewModel: SearchViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(directory) { account in
                    Button {
                        viewModel.currentPresentedAccount = account
                    } label: {
                        VStack {
                            AccountImage(author: account)
                                .profileSize(.xlarge)
                            EmojiText(
                                markdown: account.getAccountName(),
                                emojis: (enforcedFrugalMode || frugalMode) ? [] : account.emojis.map(\.remoteEmoji)
                            )
                            .font(.headline)
                            Text("@\(account.acct)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .frame(width: 100)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    }
                    .tint(.primary)
                }
            }
        }
    }
}

struct SearchDirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScrollView {
                SearchDirectoryView(directory: .init(repeating: MockData.profile!, count: 10), viewModel: .init())
            }
        }
    }
}
