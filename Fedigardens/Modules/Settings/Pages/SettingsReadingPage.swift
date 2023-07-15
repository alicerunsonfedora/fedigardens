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

import GardenSettings
import SwiftUI

struct SettingsReadingPage: View {
    @AppStorage(.useFocusedInbox) var hidesReblogsAndReplies = false
    @AppStorage(.showsStatistics) var showsStatistics: Bool = true
    @AppStorage(.alwaysShowUserHandle) var alwaysShowsUserHandle: Bool = true
    @AppStorage(.preferMatrixConversations) var preferMatrixConversations: Bool = true
    @AppStorage(.statusListPreviewLineCount) var statusListPreviewLineCount: Int = 2
    @ScaledMetric private var size = 1.0

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $alwaysShowsUserHandle) {
                    Text("settings.showhandle.title")
                }
                Picker("settings.timeline.linelimit", selection: $statusListPreviewLineCount) {
                    ForEach(2...5, id: \.self) { lineCount in
                        Text("settings.timeline.linelimit-fmt".localized(lineCount))
                            .tag(lineCount)
                    }
                }
                Toggle(isOn: $showsStatistics) {
                    Text("settings.show-statistics.title")
                }
            } footer: {
                Text("settings.show-statistics.detail")
            }

            Section {
                Toggle(isOn: $hidesReblogsAndReplies) {
                    Text("settings.showoriginal.title")
                }
            } footer: {
                Text("settings.showoriginal.detail")
            }

            Section {
                Toggle(isOn: $preferMatrixConversations) {
                    Text("settings.prefermatrix.title")
                }
            } footer: {
                Text("settings.prefermatrix.detail")
            }
        }
        .navigationTitle("settings.section.reading")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsReadingPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsReadingPage()
        }
    }
}
