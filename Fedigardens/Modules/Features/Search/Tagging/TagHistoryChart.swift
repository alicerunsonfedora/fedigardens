//
//  TagHistoryChart.swift
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

import Alice
import Charts
import SwiftUI

struct TagHistorySeries: Identifiable {
    let stat: String
    let dataPoint: [TagHistoryDataPoint]

    var id: String { stat }
}

struct TagHistoryDataPoint: Identifiable {
    let date: Date
    let dataPoint: Int

    var id: Double { date.timeIntervalSince1970 }
}

struct TagHistoryChart: View {
    var history: [History]

    private var series: [TagHistorySeries] {
        [
            .init(
                stat: "search.tag.chartuse".localized(),
                dataPoint: history.map { TagHistoryDataPoint(date: $0.date(), dataPoint: $0.numberOfUses()) }
            ),
            .init(
                stat: "search.tag.chartacct".localized(),
                dataPoint: history.map { TagHistoryDataPoint(date: $0.date(), dataPoint: $0.numberOfAccounts()) }
            )
        ]
    }

    var body: some View {
        Chart(series) { seriesPoint in
            ForEach(seriesPoint.dataPoint) { element in
                LineMark(
                    x: .value("Day", element.date, unit: .day),
                    y: .value("Data Point", element.dataPoint)
                )
                .foregroundStyle(by: .value("Data Point", seriesPoint.stat))
                .symbol(by: .value("Data Point", seriesPoint.stat))
            }
        }
    }
}
