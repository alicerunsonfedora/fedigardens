//
//  DiscussionVerifiedBadge.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/8/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import GardenProfiles
import SwiftUI
import WebString

/// A verified badge that can appear on a discussion.
///
/// This badge is commonly used to indicate that the author of a discussion has verified themselves on Mastodon by
/// proving they control a specified domain or website. Tapping on this badge will display information about the
/// verification status.
public struct DiscussionVerifiedBadge: View {
    @State private var showVerifiedInformation = false

    var status: Status

    /// Creates a verified badge for a specified discussion.
    public init(status: Status) {
        self.status = status
    }

    private var verifiedAccountDomain: String? {
        if let reblog = status.reblog, case .verified(let domain) = reblog.account.verification {
            return domain
        }
        if case .verified(let domain) = status.account.verification {
            return domain
        }
        return nil
    }

    public var body: some View {
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
                Text(AttributedString(html: String(format: NSLocalizedString("status.verified.detail",
                                                                             comment: "Verified domain"),
                                                   status.originalAuthor.accountName,
                                                   verifiedAccountDomain ?? "")))
                .font(.subheadline)
            }
            .tint(.green)
            .padding()
            .frame(minWidth: 200, idealWidth: 350, maxWidth: 400)
        }
    }
}
