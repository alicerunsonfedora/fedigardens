//
//  SettingsLicensePage.swift
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

struct SettingsLicensePage: View {
    @State private var licenseText: String = ""

    var body: some View {
        Group {
            if licenseText.isEmpty {
                VStack {
                    ProgressView()
                }
            } else {
                RunestoneViewer(text: licenseText)
            }
        }
        .navigationTitle("settings.about.license")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(), value: licenseText)
        .onAppear {
            Task {
                await fetchLicense()
            }
        }
    }

    private func fetchLicense() async {
        guard let resource = Bundle.main.path(forResource: "CNPL", ofType: "md") else { return }
        guard let string = try? String(contentsOfFile: resource) else { return }
        licenseText = string
//        let attributedString = try? AttributedString(
//            markdown: string,
//            options: .init(
//                allowsExtendedAttributes: true,
//                interpretedSyntax: .inlineOnlyPreservingWhitespace
//            )
//        )
//        DispatchQueue.main.async {
//            if let text = attributedString {
//                self.licenseText = text
//            }
//        }
    }
}
