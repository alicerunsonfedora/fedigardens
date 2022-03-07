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

import Chica
import Foundation
import SwiftUI

// MARK: - Status Detail View

/// A view that displays the detail view for a master-detail view of statuses.
///
/// Typically, this will display a status and its replies. If no replies are available, a view is present to respond
/// to the post. If passive activities are enabled, buttons for liking and boosting the status are present.
struct StatusDetailView: View {
    @Environment(\.openURL) var openURL

    /// The status that will be rendered in this view.
    @State var status: Status

    /// The context for the current status, which contains its replies and preceding statuses.
    @State private var statusCtx: Context? = nil

    /// Whether the author view should be presented.
    ///
    /// Defaults to `false`, and only becomes `true` on iOS via a button press.
    @State private var composeReply: Bool = false

    /// Whether to show passive activities.
    ///
    /// Passive activites are described as actions that the user can perform without actively engaging in the content.
    /// These include liking, boosting, and/or bookmarking a post.
    @AppStorage("experiments.shows-passive-activities", store: .standard)
    private var showsPassiveActivities: Bool = true

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
                } catch {}
            }
        }
        .navigationTitle("general.status")
#if os(macOS)
            .navigationSubtitle(makeSubtitle())
#endif
            .toolbar {
                ToolbarItemGroup {
                    replyButton
                }

                ToolbarItemGroup {
                    if showsPassiveActivities {
                        Button {
                            Task {
                                await toggleFavoriteStatus()
                            }
                        } label: {
                            Label(
                                "status.likeaction",
                                systemImage: status.favourited == true ? "star.fill" : "star"
                            )
                        }
                        .help("help.likestatus")

                        Button {
                            Task {
                                await toggleReblogStatus()
                            }
                        } label: {
                            Label(
                                "status.reblogaction",
                                systemImage: status.reblogged == true
                                    ? "arrow.triangle.2.circlepath.circle.fill"
                                    : "arrow.triangle.2.circlepath.circle"
                            )
                        }
                        .help("help.booststatus")
                    }

//                Button {
//
//                } label: {
//                    Text("Bookmark")
//                }
                }
            }
            .sheet(isPresented: $composeReply) {
                NavigationView {
                    AuthorView(prompt: status, visibility: status.visibility)
                }
#if os(iOS)
                .navigationViewStyle(.stack)
#endif
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
#if os(macOS)
            if let url = URL(string: "shout://create?reply_id=\(status.id)") {
                openURL(url)
            }
#else
            composeReply.toggle()
#endif
        } label: {
            Label("status.replyaction", systemImage: "arrowshape.turn.up.backward")
        }
        .help("help.replystatus")
    }

    private func makeSubtitle() -> String {
        String(
            format: NSLocalizedString("status.commentary", comment: ""),
            status.repliesCount
        )
    }

    // MARK: Status Actions

    // Toggles whether the user likes the status.
    private func toggleFavoriteStatus() async {
        await updateStatus { state in
            try await Chica.shared.request(
                .post, for: state.favourited == true ? .unfavorite(id: state.id) : .favourite(id: state.id)
            )
        }
    }

    // Toggles whether the user boosts the status.
    private func toggleReblogStatus() async {
        await updateStatus { state in
            try await Chica.shared.request(
                .post, for: state.reblogged == true ? .unreblog(id: state.id) : .reblog(id: state.id)
            )
        }
    }

    /// Make a request to update the current status.
    /// - Parameter means: A closure that will be performed to update the status. Should return an optional status,
    ///     which represents the newly modified status.
    private func updateStatus(by means: (Status) async throws -> Status?) async {
        var updated: Status?

        do {
            updated = try await means(status)
        } catch {
            print("Error occured when updating status: \(error.localizedDescription)")
            return
        }

        if let new = updated {
            status = new
        }
    }
}

// MARK: - Previews

struct StatusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatusDetailView(status: MockData.status!)
    }
}
