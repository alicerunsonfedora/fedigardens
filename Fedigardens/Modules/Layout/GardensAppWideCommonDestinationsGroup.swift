//
//  GardensAppWideCommonDestinationsGroup.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/21/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct GardensAppWideCommonDestinationsGroup: View {
    var body: some View {
        Group {
            GardensPageLink(page: .forYou)
            GardensPageLink(page: .local)
            GardensPageLink(page: .public)
            GardensPageLink(page: .messages)
            GardensPageLink(page: .selfPosts)
            GardensPageLink(page: .mentions)
            GardensPageLink(page: .saved)
            GardensPageLink(page: .settings)
        }
    }
}
