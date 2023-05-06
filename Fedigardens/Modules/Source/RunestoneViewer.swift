//
//  RunestoneViewer.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/5/23.
//

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
