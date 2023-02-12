//
//  StatusVerifiedButton.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/26/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Alice

struct StatusVerifiedButton: View {
    @State private var showVerifiedInformation = false

    var status: Status

    private var verifiedAccountDomain: String? {
        if let reblog = status.reblog {
            return reblog.account.verifiedDomain()
        }
        return status.account.verifiedDomain()
    }

    var body: some View {
        Button {
            showVerifiedInformation.toggle()
        } label: {
            Image(systemName: "checkmark.seal")
                .foregroundColor(.green)
                .imageScale(.small)
        }.popover(isPresented: $showVerifiedInformation) {
            VStack(alignment: .leading) {
                Label("status.verified.title", systemImage: "checkmark.seal")
                    .font(.headline)
                Text(
                    String(
                        format: NSLocalizedString("status.verified.detail", comment: "Verified domain"),
                        status.originalAuthor().getAccountName(),
                        verifiedAccountDomain ?? ""
                    ).attributedHTML()
                )
                .font(.subheadline)
            }
            .tint(.green)
            .padding()
            .frame(minWidth: 200, idealWidth: 350, maxWidth: 400)
        }
    }
}
