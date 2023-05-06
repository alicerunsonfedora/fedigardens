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

import Alice
import SwiftUI

struct SettingsAuthorPage: View {
    @AppStorage(.characterLimit) var characterLimit: Int = 500
    @AppStorage(.enforceCharacterLimit) var enforceLimit: Bool = true
    @AppStorage(.addQuoteParticipant) var addQuoteParticipant: Bool = true
    @AppStorage(.defaultVisibility) var defaultVisibility = PostVisibility.public
    @AppStorage(.defaultReplyVisibility) var defaultReplyVisibility = PostVisibility.unlisted
    @AppStorage(.defaultQuoteVisibility) var defaultQuoteVisibility = PostVisibility.public
    @AppStorage(.defaultFeedbackVisibility) var defaultFeedbackVisibility = PostVisibility.direct
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
            } header: {
                Text("settings.author.characterlimitsection")
            } footer: {
                Text("settings.author.characterlimit.detail")
            }

            Section {
                picker(for: $defaultVisibility, title: "settings.author.defaultvisibility.text")
                picker(for: $defaultReplyVisibility, title: "settings.author.replyvisibility.text")
                picker(for: $defaultQuoteVisibility, title: "settings.author.quotevisibility.text")
                picker(for: $defaultFeedbackVisibility, title: "settings.author.feedbackvisibility.text")
            } header: {
                Text("settings.author.visibilitysection")
            } footer: {
                Text("settings.author.visibilityfooter")
            }

            Section {
                Toggle(isOn: $addQuoteParticipant) {
                    Text("settings.author.quoteparticipant")
                }
            } header: {
                Text("settings.author.quotesection")
            }
        }
        .navigationTitle("settings.section.author")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            characterLimitString = String(characterLimit)
        }
    }

    private func picker(for target: Binding<PostVisibility>, title: LocalizedStringKey) -> some View {
        LabeledContent {
            Menu(target.wrappedValue.localizedDescription) {
                Picker("", selection: target) {
                    ForEach(PostVisibility.allCases, id: \.hashValue) { visibility in
                        Text(visibility.localizedDescription)
                            .tag(visibility)
                    }
                }
                .pickerStyle(.inline)
                .layoutPriority(1)
            }
        } label: {
            Text(title)
                .layoutPriority(-1)
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
