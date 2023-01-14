//
//  Label+SettingsStyle.swift
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

struct SettingsLabelStyle: LabelStyle {
    var color: Color
    var size: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        Label { configuration.title } icon: {
            configuration.icon
                .imageScale(.small)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 8 * size)
                        .frame(width: 28 * size, height: 28 * size)
                        .foregroundColor(color)
                )
        }
    }
}

extension LabelStyle where Self == SettingsLabelStyle {
    static func settings(color: Color, size: CGFloat) -> Self {
        SettingsLabelStyle(color: color, size: size)
    }
}
