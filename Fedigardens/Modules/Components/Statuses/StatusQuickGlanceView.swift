//
//  StatusQuickGlanceView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/7/23.
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

struct StatusQuickGlanceView: View {
    var status: Status

    var body: some View {
        HStack {
            if status.bookmarked == true || status.reblog?.bookmarked == true {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.indigo)
            }
            if status.favourited == true || status.reblog?.favourited == true {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            if status.reblogged == true || status.reblog?.reblogged == true {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .foregroundColor(.blue)
            }
            if status.favourited != true, status.bookmarked != true, status.reblogged != true {
                Image(systemName: "circle")
                    .foregroundColor(Color(uiColor: .systemBackground))
                    .opacity(0)
            }
        }
        .font(.caption)
    }
}
