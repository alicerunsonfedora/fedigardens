//
//  AuthenticationGateBrowser.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import SafariView
import SwiftUI

/// A browser window used in the authentication view for rendering OAuth webpages in Gopherdon.
struct AuthenticationGateBrowser: View {
    /// The URL that the browser will open when the view is rendered.
    ///
    /// If this value is `nil`, an error screen will appear instead, informing the user that the URL could not
    /// be opened.
    @Binding var url: URL?

    var body: some View {
        Group {
            SafariView(url: $url)
                .prefersReaderMode(.constant(false))
                .collapsible(.constant(false))
        }
    }
}
