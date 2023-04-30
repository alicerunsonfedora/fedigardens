//
//  StatusAuthorExtendedLabel.swift
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
import EmojiText

struct StatusAuthorExtendedLabel: View {
    @AppStorage(.frugalMode) var frugalMode: Bool = false
    @Environment(\.customEmojis) var emojis

    enum VerificationPlacementPolicy {
        case byAuthorName
        case underAuthorLabel
        case hidden
    }

    var status: Status
    var placementPolicy: VerificationPlacementPolicy
    var showUserHandle = true

    private var hasVerifiedAccount: Bool {
        if let reblog = status.reblog {
            return reblog.account.verified()
        }
        return status.account.verified()
    }

    var verifiedAccountDomain: String? {
        if let reblog = status.reblog {
            return reblog.account.verifiedDomain()
        }
        return status.account.verifiedDomain()
    }

    private var isDevelopmentMember: Bool {
        return ["marquiskurt@iosdev.space", "marquiskurt", "fedigardens@indieapps.space", "fedigardens"]
            .contains(status.originalAuthor().acct)
    }

    private var allEmojis: [RemoteEmoji] {
        if frugalMode { return [] }
        let emojisFromStatus = status.account.emojis + (status.reblog?.account.emojis ?? [])
        return emojis + emojisFromStatus.map { emoji in emoji.remote() }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                EmojiText(
                    markdown: status.reblog?.account.getAccountName() ?? status.account.getAccountName(),
                    emojis: allEmojis
                )
                .font(.system(.callout, design: .rounded))
                .bold()
                .lineLimit(1)
                if hasVerifiedAccount, placementPolicy == .byAuthorName {
                    StatusVerifiedButton(status: status)
                }
                if isDevelopmentMember, placementPolicy == .byAuthorName {
                    Image(systemName: "camera.macro")
                        .imageScale(.small)
                        .foregroundColor(.indigo)
                }
            }
            if showUserHandle {
                Text("(@\(status.reblog?.account.acct ?? status.account.acct))")
                    .foregroundColor(.secondary)
                    .font(.system(.callout, design: .rounded))
                    .lineLimit(1)
            }
            if isDevelopmentMember, placementPolicy == .underAuthorLabel {
                developerLabel
            } else if hasVerifiedAccount, placementPolicy == .underAuthorLabel {
                verifiedLabel
            }

        }
    }

    var verifiedLabel: some View {
        VStack(alignment: .leading) {
            Label {
                EmojiText(
                    markdown: String(
                        format: NSLocalizedString("status.verified.detail", comment: "Verified domain"),
                        status.originalAuthor().getAccountName(),
                        verifiedAccountDomain ?? ""
                    ).markdown(),
                    emojis: allEmojis
                )
            } icon: {
                Image(systemName: "checkmark.seal.fill")
                    .imageScale(.large)
                    .foregroundColor(.green)
            }
            .font(.footnote)
            .bold()
            .tint(.green)
        }
    }

    var developerLabel: some View {
        VStack(alignment: .leading) {
            Label {
                EmojiText(
                    markdown: String(
                        format: NSLocalizedString("status.developer.detail", comment: "Developer"),
                        status.originalAuthor().getAccountName()
                    ).markdown(),
                    emojis: allEmojis
                )
            } icon: {
                Image(systemName: "camera.macro")
                    .imageScale(.large)
                    .foregroundColor(.indigo)
            }
            .font(.footnote)
            .bold()
            .tint(.indigo)
        }
    }
}
