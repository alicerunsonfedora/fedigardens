// 
//  SettingsView.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 22/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import SwiftUI

struct SettingsView: View {

    @AppStorage("experiments.shows-passive-activities", store: .standard)
    var showsPassiveActivities: Bool = true

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $showsPassiveActivities) {
                    VStack(alignment: .leading) {
                        Text("settings.passiveactivities.title")
#if os(macOS)
                        Text("settings.passiveactivities.detail")
                            .foregroundColor(.secondary)
#endif
                    }
                }
            } footer: {
#if os(iOS)
                Text("settings.passiveactivities.detail")
#endif
            }

        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(maxWidth: 500)
    }
}
