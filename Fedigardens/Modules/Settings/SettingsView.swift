//
//  SettingsView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 22/2/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Alice

// MARK: - Settings View

struct SettingsView: View {
    @AppStorage(.showsStatistics) var showsStatistics: Bool = true
    @AppStorage(.loadLimit) var loadLimit: Int = 10
    @State private var promptSignOff = false
    @ScaledMetric private var size = 1.0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $loadLimit, step: 5) {
                        Label(
                            String(format:
                                    NSLocalizedString("settings.loadlimit.text", comment: "load limit"),
                                   String(loadLimit)),
                            systemImage: "tray.and.arrow.down.fill"
                        )
                        .labelStyle(.settings(color: .accentColor, size: size))
                    }
                } footer: {
                    Text("settings.loadlimit.detail")
                }

                Section {
                    Toggle(isOn: $showsStatistics) {
                        Label("settings.show-statistics.title", systemImage: "star.fill")
                            .labelStyle(.settings(color: .yellow, size: size))
                    }
                } footer: {
                    Text("settings.show-statistics.detail")
                }

                Section {
                    NavigationLink {
                        SettingsAuthorPage()
                    } label: {
                        Label("settings.section.author", systemImage: "square.and.pencil")
                            .labelStyle(.settings(color: .indigo, size: size))
                    }
                    NavigationLink {
                        SettingsInterventionPage()
                    } label: {
                        Label("settings.section.interventions", systemImage: "hand.raised.fingers.spread.fill")
                            .labelStyle(.settings(color: .green, size: size))
                    }
                }

                Section {
                    NavigationLink {
                        SettingsAboutPage()
                    } label: {
                        Label("settings.section.about", systemImage: "info.circle.fill")
                            .labelStyle(.settings(color: .blue, size: size))
                    }
                }

                Section {
                    Button(role: .destructive) {
                        promptSignOff.toggle()
                    } label: {
                        Label("settings.signout.link", systemImage: "door.right.hand.open")
                            .labelStyle(.settings(color: .red, size: size))
                    }
                }
            }
        }
        .navigationTitle("general.settings")
        .alert("settings.signout.title", isPresented: $promptSignOff) {
            Button(role: .destructive) {
                Task { await Alice.OAuth.shared.signOut() }
            } label: {
                Text("settings.signout.prompt")
            }
            Button(role: .cancel) {
                promptSignOff = false
            } label: {
                Text("settings.signout.cancel")
            }
        } message: {
            Text("settings.signout.detail")
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
