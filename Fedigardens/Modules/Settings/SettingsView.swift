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
    @AppStorage("status.show-statistics") var showsStatistics: Bool = true
    @AppStorage("network.load-limit") var loadLimit: Int = 10
    @State private var shouldOpenFeedbackTool: AuthoringContext?
    @State private var promptSignOff = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(
                        String(format:
                                NSLocalizedString("settings.loadlimit.text", comment: "load limit"),
                               String(loadLimit)
                              ),
                        value: $loadLimit,
                        step: 5
                    )
                } footer: {
                    Text("settings.loadlimit.detail")
                }

                Section {
                    Toggle(isOn: $showsStatistics) {
                        VStack(alignment: .leading) {
                            Text("settings.show-statistics.title")
                        }
                    }
                } footer: {
                    Text("settings.show-statistics.detail")
                }

                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(Bundle.main.getAppVersion())
                            .foregroundColor(.secondary)
                    }
                    NavigationLink {
                        NavigationStack {
                            SettingsAcknowledgementList()
                        }
                    } label: {
                        Text("acknowledge.title")
                    }

                }

                Section {
                    GardensComposeButton(
                        shouldInvokeParentSheet: $shouldOpenFeedbackTool,
                        context: .init(participants: "@ubunturox104@vivaldi.net", visibility: .unlisted),
                        style: .feedback
                    )
                    Button(role: .destructive) {
                        promptSignOff.toggle()
                    } label: {
                        Label("settings.signout.prompt", systemImage: "door.right.hand.open")
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
        .sheet(item: $shouldOpenFeedbackTool) { content in
            NavigationStack {
                AuthorView(authoringContext: content)
            }
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(maxWidth: 500)
    }
}
