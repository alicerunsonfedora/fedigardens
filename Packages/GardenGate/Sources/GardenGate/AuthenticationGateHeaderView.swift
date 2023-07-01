//
//  AuthenticationGateHeaderView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/7/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct AuthenticationGateHeaderView: View {
    var compact: Bool
    var alignment: HorizontalAlignment = .center

    var body: some View {
        VStack(alignment: alignment) {
            if !compact {
                Image("GardensIcon")
                    .symbolRenderingMode(.palette)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)
                    .cornerRadius(16)
            }
            Text("auth.welcome", bundle: .module)
                .font(.system(.title2, design: .rounded))
                .bold()
            Text("auth.appname", bundle: .module)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.accentColor)
        }
        .animation(.bouncy, value: compact)
    }
}

struct AuthenticationGateHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthenticationGateHeaderView(compact: true, alignment: .leading)
            AuthenticationGateHeaderView(compact: true, alignment: .center)
            AuthenticationGateHeaderView(compact: false, alignment: .leading)
        }
    }
}
