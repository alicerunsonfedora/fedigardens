//
//  SettingsVersionBlock.swift
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

struct SettingsVersionBlock: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Image("GardensIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 64, idealWidth: 84, maxWidth: 96)
                Text("general.appname")
                    .font(.title2)
                    .bold()
                Text("v" + Bundle.main.getAppVersion())
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            Spacer()
        }
        .padding(.vertical)
    }
}
