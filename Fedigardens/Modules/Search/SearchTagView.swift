//
//  SearchTagView.swift
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

struct SearchTagView: View {
    var tag: Tag

    var accountsUsingTag: Int {
        guard let accounts = tag.history?.map(\.accounts) else { return 0 }
        return accounts.map { Int($0) ?? 0 }.reduce(0, +) / accounts.count
    }

    var body: some View {
        Label {
            VStack(alignment: .leading) {
                Text(tag.name)
                    .font(.headline)
                Text(
                    String(format: "search.tagspeople".localized(), accountsUsingTag)
                )
                    .font(.subheadline)
            }
        } icon: {
            Image(systemName: "tag")
        }
    }
}
