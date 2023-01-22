//
//  SettingsReadingPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/22/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct SettingsReadingPage: View {
    @AppStorage(.showsStatistics) var showsStatistics: Bool = true
    @AppStorage(.loadLimit) var loadLimit: Int = 10
    @ScaledMetric private var size = 1.0

    var body: some View {
        Form {
            Section {
                Stepper(value: $loadLimit, step: 5) {
                    Text(
                        String(format:
                                NSLocalizedString("settings.loadlimit.text", comment: "load limit"),
                               String(loadLimit))
                    )
                }
            } footer: {
                Text("settings.loadlimit.detail")
            }

            Section {
                Toggle(isOn: $showsStatistics) {
                    Text("settings.show-statistics.title")
                }
            } footer: {
                Text("settings.show-statistics.detail")
            }

        }.navigationTitle("settings.section.reading")
    }
}

struct SettingsReadingPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsReadingPage()
        }
    }
}
