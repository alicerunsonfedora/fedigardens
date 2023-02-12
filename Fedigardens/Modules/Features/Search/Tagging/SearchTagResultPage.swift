//
//  SearchTagResultPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/28/23.
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
import Charts
import Bunker

struct SearchTagResultPage: View {
    var tag: Tag
    @StateObject private var viewModel = SearchTagViewModel()

    var body: some View {
        List {
            Section {
                if let history = viewModel.tag?.history {
                    TagHistoryChart(history: history)
                }
            } header: {
                Text("search.tag.history")
            }
            .listRowBackground(Color.clear)

            Group {
                if let statuses = viewModel.timeline, statuses.isNotEmpty {
                    Section {
                        ForEach(statuses, id: \.uuid) { status in
                            StatusView(status: status)
                                .lineLimit(3)
                                .profilePlacement(.hidden)
                                .datePlacement(.automatic)
                                .profileImageSize(44)
                                .verifiedNoticePlacement(.byAuthorName)
                                .tint(.secondary)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.tag?.name.capitalized ?? "Tag")
        .onAppear {
            viewModel.tag = tag
            Task {
                await viewModel.fetchTimeline()
            }
        }
        .onChange(of: tag) { newTag in
            viewModel.tag = newTag
            Task {
                await viewModel.fetchTimeline()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await viewModel.subscribeToTag()
                    }
                } label: {
                    Label("search.tag.subscribe", systemImage: "dot.radiowaves.up.forward")
                }
                .disabled(tag.following == true)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .labelStyle(.titleAndIcon)
            }

            ToolbarItem {
                if let url = URL(string: viewModel.tag?.url ?? "") {
                    Link(destination: url) {
                        Label("status.webaction", systemImage: "safari")
                    }
                }
            }
        }
    }
}
