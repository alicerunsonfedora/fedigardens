//
//  StatusListMDView.swift
//  Gardens
//
//  Created by Marquis Kurt on 11/2/22.
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

// MARK: - Status Navigation List

struct StatusNavigationList<Extras: View>: View {
    @Environment(\.openWindow) private var openWindow
    @State var statuses: [Status]
    @Binding var selectedStatus: Status?
    @StateObject private var viewModel: StatusNavigationListViewModel = .init()

    var extras: (() -> Extras)?

    var body: some View {
        List(selection: $selectedStatus) {
            ForEach(viewModel.statuses, id: \.id) { status in
                NavigationLink(value: status) {
                    HStack(alignment: .top) {
                        if status.favourited == true {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        } else {
                            Image(systemName: "circle.fill")
                                .opacity(0)
                                .font(.caption)
                        }
                        statusLink(for: status)
                            .allowsHitTesting(false)
                    }
                }
            }
            if let extras {
                extras()
            }
        }
        .onAppear {
            viewModel.insert(statuses: statuses)
        }
    }

    private func statusLink(for status: Status) -> some View {
        StatusView(status: status)
            .lineLimit(2)
            .profilePlacement(.hidden)
            .datePlacement(.automatic)
            .profileImageSize(44)
            .verifiedNoticePlacement(.byAuthorName)
            .tint(.secondary)
            .swipeActions(edge: .leading) {
                Button {
                    Task {
                        await viewModel.toggleFavorite(status: status)
                    }
                } label: {
                    Label("status.likeaction", systemImage: "star")
                }.tint(.yellow)
            }
            .swipeActions {
                Button {
                    let context = AuthoringContext(replyingToID: status.id)
                    openWindow(value: context)
                } label: {
                    Label("status.replyaction", systemImage: "arrowshape.turn.up.backward")
                }.tint(.accentColor)

                Button {
                    let context = AuthoringContext(forwardingURI: status.uriToURL()?.absoluteString ?? "")
                    openWindow(value: context)
                } label: {
                    Label("status.forwardaction", systemImage: "quote.bubble")
                }.tint(.indigo)
            }
            .contextMenu {
                Button {
                    openWindow(value: status)
                } label: {
                    Label("general.newwindow", systemImage: "rectangle.badge.plus")
                }
                Button {
                    let context = AuthoringContext(replyingToID: status.id)
                    openWindow(value: context)
                } label: {
                    Label("status.replyaction", systemImage: "arrowshape.turn.up.backward")
                }

                Button {
                    let context = AuthoringContext(forwardingURI: status.uriToURL()?.absoluteString ?? "")
                    openWindow(value: context)
                } label: {
                    Label("status.forwardaction", systemImage: "quote.bubble")
                }
            }
    }
}

// MARK: - Previews

struct StatusListMDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatusNavigationList(
                statuses: MockData.timeline!,
                selectedStatus: .constant(nil)
            ) { EmptyView() }
        }
        .frame(minWidth: 700)
    }
}
