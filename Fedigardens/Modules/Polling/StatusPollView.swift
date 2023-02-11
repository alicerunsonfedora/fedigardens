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
import Charts
import Alice

struct StatusPollView: View {
    var poll: Poll

    private var totalPercentage: Float {
        Float(max(1, poll.votesCount))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Chart {
                ForEach(poll.options) { option in
                    BarMark(
                        x: .value(option.title, option.votesCount ?? 0),
                        y: .value("Poll Option", option.title)
                    )
                    .annotation(position: .trailing) {
                        Text(
                            getPercentage(from: option.votesCount ?? 0),
                            format: .percent.precision(.fractionLength(0..<1))
                        )
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                    }
                }
            }
            .chartXAxisLabel("Total Votes: \(poll.votesCount)")
            .frame(height: 150)
            .frame(minWidth: 256, maxWidth: 600)

            Group {
                if poll.expired == true {
                    Label("status.poll.expired", systemImage: "info.circle")
                } else if poll.voted == true {
                    Label("status.poll.voted", systemImage: "checkmark.circle")
                }
            }
            .font(.footnote)
            .bold()
            .foregroundColor(.secondary)

        }
    }

    private func getPercentage(from votes: Int) -> Float {
        return Float(votes) / totalPercentage
    }
}

struct StatusPollView_Previews: PreviewProvider {
    static var previews: some View {
        StatusPollView(poll: MockData.poll!)
            .padding()
    }
}
