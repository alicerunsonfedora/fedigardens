//
//  GardensAppTrendingTagsDestination.swift
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

import Alice
import SwiftUI

struct GardensAppTrendingTagsDestination: View {
    @StateObject var viewModel: GardensAppLayoutViewModel

    var body: some View {
        Section {
            ForEach(viewModel.tags) { tag in
                NavigationLink(value: GardensAppPage.trending(id: tag.name)) {
                    Label(tag.name, systemImage: "tag")
                }
            }
        } header: {
            Text(GardensAppPage.trending(id: "0").localizedTitle)
        }
    }
}
