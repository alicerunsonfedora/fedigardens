// 
//  CompactLayout.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 12/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import SwiftUI
import Chica

// MARK: - Compact Layout
/// A view that represents the layout for compact devices.
/// This is commonly used on iOS devices such as iPhone.
struct CompactLayout: View {
    var body: some View {
        Text("E")
    }
}

// MARK: - Previews
struct CompactLayout_Previews: PreviewProvider {
    static var previews: some View {
        CompactLayout()
            .previewDevice("iPhone 13")
    }
}
