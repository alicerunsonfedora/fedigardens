//
//  StatusDetailProfileMenu.swift
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

import Alice
import GardenComposer
import SwiftUI

struct StatusDetailProfileMenu: View {
    @Environment(\.openURL) private var openURL
    @AppStorage(.preferMatrixConversations) private var prefersMatrixConversations: Bool = true
    @Binding var displayedProfile: Account?
    @Binding var composer: AuthoringContext?
    var account: Account

    var body: some View {
        Group {
            Section {
                Button {
                    displayedProfile = account
                } label: {
                    Label("status.profileaction.generic", systemImage: "person.circle")
                }
                GardensComposeButton(
                    shouldInvokeParentSheet: $composer,
                    context: AuthoringContext(
                        participants: "@\(account.acct)"
                    ),
                    style: .mention
                )
                Group {
                    if prefersMatrixConversations, let id = account.matrixID() {
                        Button {
                            let transformed = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            if let url = URL(string: "https://matrix.to/#/\(transformed ?? "")") {
                                openURL(url)
                            }
                        } label: {
                            Label {
                                Text("profile.matrixaction")
                            } icon: {
                                Image("matrix")
                            }
                        }
                    } else {
                        GardensComposeButton(
                            shouldInvokeParentSheet: $composer,
                            context: AuthoringContext(
                                participants: "@\(account.acct)",
                                visibility: .direct
                            ),
                            style: .message
                        )
                    }
                }
            } header: {
                Text(account.getAccountName())
            }
        }
    }
}
