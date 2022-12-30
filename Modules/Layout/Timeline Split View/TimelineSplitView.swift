//
//  WidescreenHomeView.swift
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

#if iOS
import UIKit
#endif

/// A view used to render a timeline in the widescreen layout.
struct TimelineSplitView: View, LayoutStateRepresentable {
    @Environment(\.openURL) var openURL
    @State var state: LayoutState = .initial
    @State var scope: TimelineSplitViewModel.TimelineType

    @StateObject var model: TimelineSplitViewModel = .init(scope: .scopedTimeline(scope: .home, local: false))
    @Binding var selectedStatus: Status?

    var body: some View {
        Group {
            switch state {
            case .initial, .loading:
                StatusNavigationList(
                    statuses: model.dummyTimeline,
                    selectedStatus: $selectedStatus
                ) {
                    EmptyView()
                }
                .redacted(reason: .privacy)
            case .loaded where model.timelineData.isEmpty:
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                        Text("general.emptytimeline")
                            .font(.title)

                    }.foregroundColor(.secondary)
                    Spacer()
                }
            case .loaded:
                StatusNavigationList(statuses: model.timelineData, selectedStatus: $selectedStatus) {
                    Group {
                        if case .scopedTimeline = model.scope {
                            loadNextButton
                        }
                    }
                }
                    .animation(.easeInOut, value: model.timelineData)
            case .errored(let message):
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("\(message)")
                    Button {
                        Task {
                            state = .loading
                            state = await model.loadTimeline(policy: .refreshEntireContents)
                        }
                    } label: {
                        Text("Try Again")
                    }.buttonStyle(.bordered)
                }
            }
        }
        .animation(.easeInOut, value: state)
        .onAppear {
            withAnimation {
                model.scope = scope
                Task {
                    state = await model.loadTimeline(policy: .refreshEntireContents)
                }
            }
        }
        .refreshable {
            withAnimation {
                state = .loading
                Task {
                    state = await model.loadTimeline(forcefully: true, policy: .refreshEntireContents)
                }
            }
        }
    }

    private var loadNextButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    state = .loading
                    Task {
                        state = await model.loadTimeline(forcefully: true, policy: .preloadNextBatch)
                    }
                }
            } label: {
                Label("general.loadmore", systemImage: "ellipsis.rectangle")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .controlSize(.regular)
            .tint(.accentColor)
            Spacer()
        }
        .padding(.vertical, 4)
        .listRowSeparator(.hidden, edges: .bottom)
    }
}
