//
//  RunestoneViewer.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/5/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Runestone

struct RunestoneViewer: UIViewRepresentable {
    typealias UIViewType = Runestone.TextView

    var text: String

    func makeUIView(context: Context) -> Runestone.TextView {
        let viewer = Runestone.TextView()
        viewer.backgroundColor = .systemBackground
        viewer.setLanguageMode(PlainTextLanguageMode())
        viewer.text = text
        viewer.isFindInteractionEnabled = true
        viewer.isEditable = false
        viewer.showLineNumbers = false
        viewer.lineHeightMultiplier = 1.25
        viewer.theme = DefaultTheme()
        viewer.isLineWrappingEnabled = true
        viewer.textContainerInset = .init(top: 2, left: 8, bottom: 2, right: 8)
        return viewer
    }

    func updateUIView(_ uiView: Runestone.TextView, context: Context) {}
}
