//
//  BagdedText.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/28/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct BadgedText: View {
    var text: AttributedString
    var color: Color

    init(_ text: AttributedString, color: Color) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .textCase(.uppercase)
            .bold()
            .padding(.horizontal, 6)
            .foregroundColor(color)
            .overlay {
                Capsule()
                    .strokeBorder()
                    .foregroundColor(color)
            }
    }
}
