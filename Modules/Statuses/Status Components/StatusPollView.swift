// 
//  StatusPollView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/25/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Chica

struct StatusPollView: View {
    var poll: Poll

    private var totalPercentage: Float {
        Float(max(1, poll.votesCount))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(poll.options) { option in
                HStack(spacing: 16) {
                    Text(option.title)
                        .bold()
                    ProgressView(value: Float(option.votesCount ?? 0), total: totalPercentage)
                        .progressViewStyle(.linear)
                        .frame(minWidth: 256, maxWidth: 600)
                    Spacer()
                    Text(
                        getPercentage(from: option.votesCount ?? 0),
                        format: .percent.precision(.fractionLength(0..<1))
                    )
                }
            }
            if poll.voted == true {
                Text("status.voted")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func getPercentage(from votes: Int) -> Float {
        return Float(votes) / totalPercentage
    }
}
