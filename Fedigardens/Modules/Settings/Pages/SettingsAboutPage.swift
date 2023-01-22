//
//  SettingsAboutPage.swift
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
import AckGen

struct SettingsAboutPage: View {
    @State private var shouldOpenFeedbackTool: AuthoringContext?
    @ScaledMetric private var size = 1.0

    var body: some View {
        Form {
            Section {
                LabeledContent("App Version", value: Bundle.main.getAppVersion())
                NavigationLink {
                    SettingsAcknowledgementList()
                } label: {
                    Text("acknowledge.title")
                }
            }

            Section {
                GardensComposeButton(
                    shouldInvokeParentSheet: $shouldOpenFeedbackTool,
                    context: .init(
                        participants: "@fedigardens@indieapps.space",
                        visibility: UserDefaults.standard.defaultFeedbackVisibility
                    ),
                    style: .feedback
                )
                .labelStyle(.settings(color: .accentColor, size: size))
                if let url = URL(destination: .bugs) {
                    Link(destination: url) {
                        Label("general.bugreport", systemImage: "ant")
                            .labelStyle(.settings(color: .red, size: size))
                    }
                }
            }
            .tint(.primary)
        }
        .navigationTitle("settings.section.about")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $shouldOpenFeedbackTool) { content in
            NavigationStack {
                AuthorView(authoringContext: content)
            }
        }
    }
}

struct SettingsAboutPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsAboutPage()
        }
    }
}
