//
//  SettingsInterventionPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/13/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct SettingsInterventionPage: View {
    @AppStorage(.allowsInterventions) var allowInterventions: Bool = true
    @AppStorage(.intervenesOnRefresh) var refreshIntervention: Bool = true
    @AppStorage(.intervenesOnFetch) var fetchMoreIntervention: Bool = true
    @ScaledMetric private var size = 1

    var body: some View {
        Form {
            Section {
                header
                Toggle(isOn: $allowInterventions) {
                    HStack {
                        Text("settings.interventions.allow")
                        BetaBadge()
                    }
                }
            } footer: {
                Text("settings.interventions.detail")
            }

            if allowInterventions {
                Section {
                    Toggle(isOn: $refreshIntervention) {
                        Text("settings.interventions.refresh")
                    }
                    Toggle(isOn: $fetchMoreIntervention) {
                        Text("settings.interventions.fetch")
                    }
                } header: {
                    Text("settings.interventions.grain")
                }

                Section {
                    if let link = URL(destination: .oneSecSettings) {
                        Link(destination: link) {
                            Text("settings.interventions.configure")
                        }
                    }
                }
            }
        }
        .navigationTitle("settings.section.interventions")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: allowInterventions)
    }

    private var header: some View {
        HStack {
            Spacer()
            VStack {
                HStack(spacing: 16) {
                    Image("GardensIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 32, maxWidth: 76, minHeight: 32, maxHeight: 76)
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Image("OneSec")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 32, maxWidth: 76, minHeight: 32, maxHeight: 76)
                }
                Text("settings.interventions.title")
                    .font(.title2)
                    .bold()
                Text("settings.interventions.info")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical)
            Spacer()
        }
    }
}

struct SettingsInterventionPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsInterventionPage()
        }
    }
}
