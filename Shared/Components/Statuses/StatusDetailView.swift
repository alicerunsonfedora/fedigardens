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
    @State private var statusCtx: Context? = nil

    @State private var composeReply: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                StatusView(status: status)
                    .profileImageSize(36)
                    .statistics(true)
                Divider()
                context
            }
            .padding()
        }
        .onAppear {
            Task {
                do {
                    statusCtx = try await Chica.shared.request(.get, for: .context(id: status.id))
                } catch {

                }
            }
        }
        .navigationTitle("general.status")
#if os(macOS)
        .navigationSubtitle(makeSubtitle())
#endif
        .toolbar {
            replyButton
        }
        .sheet(isPresented: $composeReply) {
            NavigationView {
                AuthorView(prompt: status, visibility: status.visibility)
            }
        }
    }

    private var context: some View {
        VStack(alignment: .leading) {
            if let replies = statusCtx?.descendants {
                if !replies.isEmpty {
                    ForEach(replies, id: \.id) { reply in
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: "text.bubble")
                                .imageScale(.large)
                            StatusView(status: reply)
                                .profilePlacement(.byAuthorName)
                                .profileImageSize(32)
                                .datePlacement(.underContent)
                                .statistics(true)
                        }
                        .padding(.top, 6)
                    }
                } else { repliesEmpty }
            } else { repliesEmpty }
        }
        .padding(.leading, 8)
    }

    private var repliesEmpty: some View {
        HStack {
            Spacer()
            VStack {
                Image(systemName: "ellipsis.bubble")
                    .imageScale(.large)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(.secondary)

                Text("status.nocontext")
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(.secondary)

                replyButton
                    .controlSize(.regular)
                    .tint(.accentColor)
                    .buttonStyle(.bordered)
            }
            .padding()
            Spacer()
        }
    }

    private var replyButton: some View {
        Button {
//#if os(macOS)
            if let url = URL(string: "starlight://create?reply_id=\(status.id)") {
                openURL(url)
            }
//#else
//            composeReply.toggle()
//#endif
        } label: {
            Label("status.replyaction", systemImage: "arrowshape.turn.up.backward")
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
