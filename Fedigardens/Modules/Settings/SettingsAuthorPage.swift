//
//  SettingsAuthorPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/21/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct SettingsAuthorPage: View {
    @AppStorage("author.characterlimit") var characterLimit: Int = 500
    @AppStorage("author.enforcelimit") var enforceLimit: Bool = true
    @State private var characterLimitString = "500"
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $enforceLimit) {
                    Text("settings.author.enforcelimit.text")
                }
                LabeledContent {
                    TextField("settings.author.characterlimit.text", text: $characterLimitString)
                        .lineLimit(1)
                        .keyboardType(.numberPad)
                        .layoutPriority(-1)
                        .multilineTextAlignment(.trailing)
                        .monospacedDigit()
                        .onChange(of: characterLimitString) { newValue in
                            characterLimit = Int(newValue) ?? 500
                        }
                } label: {
                    Text("settings.author.characterlimit.text")
                        .layoutPriority(1)
                }
            } footer: {
                Text("settings.author.characterlimit.detail")
            }
        }
        .navigationTitle("settings.section.author")
        .onAppear {
            characterLimitString = String(characterLimit)
        }
    }
}

struct SettingsAuthorPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsAuthorPage()
        }
    }
}
