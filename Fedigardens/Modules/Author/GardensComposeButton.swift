//
//  ComposeButton.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct GardensComposeButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            Button {
                openWindow(value: AuthoringContext())
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .help("help.poststatus")
        }
    }
}
