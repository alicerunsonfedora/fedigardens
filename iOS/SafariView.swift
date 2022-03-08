//
//  SafariView.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 8/3/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SafariServices
import SwiftUI

/// A view that displays an in-app browser using `SFSafariViwController`.
@available(iOS 15.0, *)
struct SafariView: UIViewControllerRepresentable {
    /// The URL to load into the Safari view controller.
    let url: URL

    /// Whether to enter reader mode by default.
    fileprivate let reader: Bool

    /// Whether to collapse the bar.
    fileprivate let collapseBar: Bool

    /// - Parameter urlString: A string containing the URL the Safari view controller will open.
    init(_ urlString: String) {
        self.init(urlString, reader: false, collapses: false)
    }

    /// - Parameter url: The URL the Safari view controller will open.
    init(_ url: URL) {
        self.init(url, reader: false, collapses: false)
    }

    fileprivate init(_ urlString: String, reader: Bool = false, collapses collapseBar: Bool = false) {
        url = URL(string: urlString)!
        self.reader = reader
        self.collapseBar = collapseBar
    }

    fileprivate init(_ url: URL, reader: Bool = false, collapses collapseBar: Bool = false) {
        self.url = url
        self.reader = reader
        self.collapseBar = collapseBar
    }

    func makeUIViewController(context _: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = reader
        configuration.barCollapsingEnabled = collapseBar
        return SFSafariViewController(url: url, configuration: configuration)
    }

    func updateUIViewController(
        _: SFSafariViewController,
        context _: UIViewControllerRepresentableContext<SafariView>
    ) {}
}

extension SafariView {
    /// Sets whether Reader Mode should open automatically when the page loads.
    func prefersReaderMode(_ prefersReaderMode: Binding<Bool>) -> SafariView {
        SafariView(url, reader: prefersReaderMode.wrappedValue, collapses: collapseBar)
    }

    /// Sets whether the browser bar automatically collapses when the user scrolls.
    func collapsible(_ collapsible: Binding<Bool>) -> SafariView {
        SafariView(url, reader: reader, collapses: collapsible.wrappedValue)
    }
}
