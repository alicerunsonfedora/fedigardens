//
//  BetaBadge.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/13/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

@available(*, deprecated, message: "Use SeedUI BadgedText instead.")
struct BetaBadge: View {
    var body: some View {
        Text("BETA")
            .font(.system(.footnote, design: .rounded))
            .bold()
            .padding(.horizontal, 6)
            .foregroundColor(.accentColor)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder()
                    .foregroundColor(.accentColor)
            }
    }
}
