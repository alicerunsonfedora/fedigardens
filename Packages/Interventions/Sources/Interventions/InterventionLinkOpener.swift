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

public protocol InterventionLinkOpener {
    func canOpenURL(_ url: URL) async -> Bool

    @discardableResult
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
}

#if os(macOS)
extension NSApplication: InterventionLinkOpener {}
#else
extension UIApplication: InterventionLinkOpener {}
#endif