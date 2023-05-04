//
//  SettingsEnergyPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 4/30/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct SettingsEnergyPage: View {
    @Environment(\.enforcedFrugalMode) var enforcedFrugalMode
    @AppStorage(.loadLimit) var loadLimit: Int = 10
    @AppStorage(.frugalMode) private var frugalMode: Bool = false

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
            .disabled(frugalMode)

            Section {
                Toggle(isOn: $frugalMode) {
                    Text("settings.frugalmode.title")
                }
                .disabled(enforcedFrugalMode)
            } footer: {
                Text("settings.frugalmode.detail")
            }
        }
        .navigationTitle("settings.section.energy")
    }
}

struct SettingsEnergyPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsEnergyPage()
        }
    }
}
