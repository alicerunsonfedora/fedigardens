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
    @StateObject var viewModel = StatusDetailViewModel()

    var status: Status
    var level: RecursiveNavigationLevel

    var body: some View {
        RecursiveNavigationStack(level: level) {
            ScrollViewReader { scrollProxy in
                switch viewModel.state {
                case .initial:
                    List {
                        StatusView(status: MockData.status!)
                            .profileImageSize(48)
                            .reblogNoticePlacement(.aboveOriginalAuthor)
                            .showsDisclosedContent($displayUndisclosedContent)
                            .verifiedNoticePlacement(.underAuthorLabel)
                            .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                        ProgressView()
                    }
                    .listStyle(.plain)
                    .redacted(reason: .placeholder)
                case .loading:
                    ProgressView()
                        .font(.largeTitle)
                case .loaded:
                    List {
                        if let quote = viewModel.quote {
                            NavigationLink(value: viewModel.contextCaller(for: quote)) {
                                StatusDetailQuote(
                                    displayUndisclosedContent: $displayUndisclosedContent,
                                    status: status,
                                    quote: quote
                                )
                            }.listRowBackground(Color.accentColor.opacity(0.1))
                        }
                        if let context = viewModel.context, context.ancestors.isNotEmpty == true {
                            if viewModel.expandAncestors {
                                StatusContextProvider(
                                    viewModel: viewModel,
                                    context: context,
                                    displayMode: .ancestors
                                )
                            } else {
                                Button {
                                    withAnimation {
                                        viewModel.expandAncestors.toggle()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation {
                                            scrollProxy.scrollTo(viewModel.status?.uuid, anchor: .top)
                                        }
                                    }
                                } label: {
                                    Label("status.prevcontext", systemImage: "ellipsis")
                                }
                            }
                        }
                        StatusView(status: status)
                            .profileImageSize(48)
                            .reblogNoticePlacement(.aboveOriginalAuthor)
                            .showsDisclosedContent($displayUndisclosedContent)
                            .verifiedNoticePlacement(.underAuthorLabel)
                            .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                            .id(viewModel.status?.uuid)
                        if let context = viewModel.context {
                            StatusContextProvider(viewModel: viewModel, context: context)
                        }
                    }
                    .listStyle(.plain)
                case .errored(let reason):
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundColor(.secondary)
                        Text(reason)
                            .font(.title3)
                    }
                }
            }
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
            if let profile {
                ProfileSheetView(profile: profile)
            }
        }
    }
}

// MARK: - Previews

struct StatusDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StatusDetailView(status: MockData.status!, level: .parent)
    }
}
