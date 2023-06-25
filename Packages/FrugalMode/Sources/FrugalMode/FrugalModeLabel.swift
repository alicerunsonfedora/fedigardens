//
//  FrugalModeLabel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 25/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

public struct FrugalModeLabel: View {
    public init() {}

    public var body: some View {
        Label {
            Text("frugalmode.on", bundle: .module)
                .font(.system(.body, design: .rounded))
        } icon: {
            Image(systemName: "leaf.fill")
        }
        .foregroundColor(.green)
    }
}

struct FrugalModeLabel_Previews: PreviewProvider {
    static var previews: some View {
        FrugalModeLabel()
    }
}
