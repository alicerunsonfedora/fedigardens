//
//  StatusDetailView.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/2/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
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
    @Environment(\.openWindow) var openWindow
    @State private var displayUndisclosedContent: Bool = false
    @StateObject var viewModel: StatusDetailViewModel = .init()

    var status: Status
    var level: RecursiveNavigationLevel

    var body: some View {
        RecursiveNavigationStack(level: level) {
            List {
                StatusView(status: status)
                    .profileImageSize(48)
                    .reblogNoticePlacement(.aboveOriginalAuthor)
                    .showsDisclosedContent($displayUndisclosedContent)
                    .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                context
            }
            .listStyle(.plain)
        }
        .recursiveDestination(of: StatusDetailViewModel.ContextCaller.self) { ctx in
            StatusDetailView(status: ctx.status, level: .child)
        }
        .onAppear {
            Task {
                await viewModel.replace(status: status)
                displayUndisclosedContent = !viewModel.containsUndisclosedContent
            }
        }
        .onChange(of: status) { newStatus in
            Task {
                await viewModel.replace(status: newStatus)
                displayUndisclosedContent = !viewModel.containsUndisclosedContent
            }
        }
        .navigationTitle(viewModel.navigationTitle(with: level))
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(id: "statusdetail") {
            StatusDetailToolbar(
                viewModel: viewModel,
                displayUndisclosedContent: $displayUndisclosedContent
            )
        }
        .toolbarRole(.editor)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: displayUndisclosedContent)
        .animation(.easeInOut, value: viewModel.context)
        .refreshable {
            Task { await viewModel.getContext() }
        }
    }

    private var context: some View {
        Section {
            if let replies = viewModel.context?.descendants, !replies.isEmpty {
                ForEach(replies, id: \.id) { reply in
                    NavigationLink(value: viewModel.contextCaller(for: reply)) {
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: "text.bubble")
                                .imageScale(.large)
                            StatusView(status: reply)
                                .profilePlacement(.byAuthorName)
                                .profileImageSize(32)
                                .datePlacement(.underContent)
                        }
                        .listRowInsets(.init(top: 8, leading: 32, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden, edges: .all)
                    }
                }
            } else { repliesEmpty }
        }
        .listRowSeparator(.hidden)
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
        .listRowSeparator(.hidden)
    }

    private var replyButton: some View {
        Button {
            let context = AuthoringContext(replyingToID: status.id)
            openWindow(id: "create", value: context)
        } label: {
            Label("status.replyaction", systemImage: "arrowshape.turn.up.backward")
        }
        .help("help.replystatus")
    }
}

// MARK: - Previews

struct StatusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatusDetailView(status: MockData.status!, level: .parent)
    }
}
