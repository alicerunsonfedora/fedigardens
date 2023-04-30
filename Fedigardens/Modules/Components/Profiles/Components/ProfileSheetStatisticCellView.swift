//
//  ProfileSheetStatisticCellView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/15/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct ProfileSheetStatisticCellView: View {
    var key: LocalizedStringKey
    var value: LocalizedStringKey
    var systemName: String = "questionmark.square.dashed"

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .foregroundColor(.accentColor)
            VStack {
                Text(value)
                    .font(.headline)
                Text(key)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
                .cornerRadius(10)
        )
    }
}
