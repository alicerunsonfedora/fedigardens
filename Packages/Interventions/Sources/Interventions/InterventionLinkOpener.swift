//
//  InterventionLinkOpener.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 26/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A protocol that defines an actor that can open links to call one sec.
public protocol InterventionLinkOpener {
    /// Returns whether the specified URL can be opened.
    /// - Parameter url: The URL that is being requested to navigate to.
    func canOpenURL(_ url: URL) async -> Bool

    /// Opens the URL with the requested options.
    /// - Parameter url: The URL to open.
    /// - Parameter options: The options used to configure how the URL is opened.
    @discardableResult
    func open(_ url: URL) async -> Bool
}

#if os(macOS)
extension NSWorkspace: InterventionLinkOpener {
    func canOpenURL(_ url: URL) { return true }
}
#else
extension UIApplication: InterventionLinkOpener {
    public func open(_ url: URL) async -> Bool {
        await self.open(url, options: [:])
    }
}
#endif
