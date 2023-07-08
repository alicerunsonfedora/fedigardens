//
//  SettingsFeedbackSection.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/29/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import SeedUI

struct SettingsFeedbackSection: View {
    @ScaledMetric private var size = 1.0

    var body: some View {
        Section {
            if let url = URL(destination: .raceway()) {
                Link(destination: url) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("settings.feedback.personal")
                                .bold()
                            Text("settings.feedback.personaldetail")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            BadgedText("general.recommend")
                                .badgeColor(.green)
                                .padding(.top, 1)
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
}
