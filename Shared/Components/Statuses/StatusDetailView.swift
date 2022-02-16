// 
//  StatusDetailView.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 12/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import SwiftUI
import Chica

// MARK: - Status Detail View
struct StatusDetailView: View {

    @Environment(\.openURL) var openURL

    @State var status: Status

    @State private var composeReply: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                StatusView(status: status)
                    .profileImageSize(36)
                Divider()
                Text("missingno")
            }
            .padding()
        }
        .navigationTitle("general.post")
#if os(macOS)
        .navigationSubtitle(makeSubtitle())
#endif
        .toolbar {
            Button {
#if os(macOS)
                if let url = URL(string: "starlight://create?reply_id=\(status.id)") {
                    openURL(url)
                }
#else
                composeReply.toggle()
#endif
            } label: {
                Image(systemName: "arrowshape.turn.up.backward")
            }
        }
        .sheet(isPresented: $composeReply) {
            NavigationView {
                AuthorView(prompt: status, visibility: status.visibility)
            }
        }
    }

    private func makeSubtitle() -> String {
        String(
            format: NSLocalizedString("status.commentary", comment: ""),
            status.repliesCount
        )
    }
}

// MARK: - Previews
struct StatusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatusDetailView(status: MockData.status!)
    }
}
