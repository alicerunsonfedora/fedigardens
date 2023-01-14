//
//  SettingsAcknowledgementList.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/31/22.
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

struct SettingsAcknowledgementList: View {
    var libraries: [Acknowledgement] {
        Acknowledgement.all() + [
            .init(title: "Alice (Chica fork)", license: Acknowledgement.license(named: "NPL")),
            .init(title: "HTML2Markdown", license: Acknowledgement.license(named: "MIT-HTML2Markdown", ofType: "md")),
            .init(title: "SafariView", license: Acknowledgement.license(named: "MPLv2"))
        ]
    }

    var assets: [Acknowledgement] {
        [
            .init(title: "App Icon", license: "Icon created by VegasOs."),
            .init(title: "one sec Icon", license: "Icon created for one sec by Frederik Riedel. All rights reserved.")
        ]
    }

    var body: some View {
        List {
            Section {
                section(of: libraries)
            } header: {
                Text("acknowledge.libraries")
            }

            Section {
                section(of: assets)
            } header: {
                Text("acknowledge.assets")
            }
        }
        .navigationTitle("acknowledge.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(of list: [Acknowledgement]) -> some View {
        ForEach(list, id: \.title) { notice in
            NavigationLink {
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        Text(notice.license)
                    }.frame(maxWidth: .infinity)
                }.navigationTitle(notice.title)
            } label: {
                Text(notice.title)
            }
        }
    }
}
