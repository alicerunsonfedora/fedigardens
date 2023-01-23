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
                if let url = URL(destination: .github) {
                    Link(destination: url) {
                        Label("settings.about.source", systemImage: "hammer.fill")
                            .labelStyle(.settings(color: .blue, size: size))
                    }
                }
                if let url = URL(destination: .changelog) {
                    Link(destination: url) {
                        Label("settings.about.changelog", systemImage: "sparkles")
                            .labelStyle(.settings(color: .yellow, size: size))
                    }
                }
                GardensComposeButton(
                    shouldInvokeParentSheet: $shouldOpenFeedbackTool,
                    context: .init(
                        participants: "@fedigardens@indieapps.space",
                        visibility: UserDefaults.standard.defaultFeedbackVisibility
                    ),
                    style: .feedback
                )
                .labelStyle(.settings(color: .accentColor, size: size))
            }
            .tint(.primary)

            Section {
                if let url = URL(destination: .feedback) {
                    Link(destination: url) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("settings.feedback.personal")
                                    .bold()
                                Text("settings.feedback.personaldetail")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                Text("general.recommend")
                                    .font(.caption2)
                                    .textCase(.uppercase)
                                    .foregroundColor(.green)
                                    .padding(.top, 1)
                                    .padding(.horizontal, 6)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24)
                                            .strokeBorder()
                                            .foregroundColor(.green)
                                    }
                            }
                        } icon: {
                            Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                        }
                        .labelStyle(.settings(color: .green, size: size))
                        .padding(.top, 2)
                    }
                }
                if let url = URL(destination: .ghBugs) {
                    Link(destination: url) {
                        Link(destination: url) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("general.bugreport")
                                        .bold()
                                    Text("settings.feedback.bugreportdetail")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                            } icon: {
                                Image(systemName: "ant.fill")
                            }
                            .labelStyle(.settings(color: .red, size: size))
                            .padding(.top, 2)
                        }
                    }
                }
            } header: {
                Label("general.feedback", systemImage: "exclamationmark.bubble")
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
