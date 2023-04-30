//
//  InformationCard.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/29/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct InformationCard<TextContent: StringProtocol>: View {
    var title: TextContent
    var systemImage: String
    var content: TextContent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.leading)
            Text(content)
                .font(.system(.subheadline, design: .rounded))
                .multilineTextAlignment(.leading)
        }
        .font(.callout)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .tertiarySystemFill).cornerRadius(10))
    }
}

struct InformationCard_Previews: PreviewProvider {
    static var previews: some View {
        InformationCard(
            title: "Unable to load data",
            systemImage: "exclamationmark.triangle",
            content: "No internet connection was established."
        )
        .padding()
    }
}
