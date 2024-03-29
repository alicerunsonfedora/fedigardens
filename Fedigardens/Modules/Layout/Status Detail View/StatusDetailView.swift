//
//  StatusDetailView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/2/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import SeedUI
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
    @StateObject var viewModel = StatusDetailViewModel()

    var status: Status
    var level: RecursiveNavigationStackLevel

    var body: some View {
        RecursiveNavigationStack(level: level) {
            StatusDetailList(
                status: status,
                viewModel: viewModel,
                displayUndisclosedContent: $displayUndisclosedContent
            )
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
        .animation(.easeInOut, value: viewModel.state)
        .refreshable {
            Task { await viewModel.getContext() }
        }
        .sheet(item: $viewModel.shouldOpenCompositionTool) { context in
            NavigationStack {
                AuthorView(authoringContext: context)
            }
        }
        .sheet(item: $viewModel.displayedProfile) { profile in
            ProfileSheetView(profile: profile)
        }
        .sheet(item: $viewModel.shouldVote) { poll in
            Group {
                PollVotingView(poll: poll)
            }
        }
        .fullScreenCover(item: $viewModel.displayAttachments) {
            viewModel.displayAttachments = nil
        } content: { context in
            AttachmentViewer(attachments: context.attachments)
        }
    }
}

// MARK: - Previews

struct StatusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatusDetailView(status: MockData.status!, level: .parent)
    }
}
