//
//  WidescreenHomeView.swift
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
import SwiftUI
import UIKit

/// A view used to render a timeline in the widescreen layout.
struct TimelineSplitView: View, LayoutStateRepresentable {
    @Environment(\.openURL) var openURL

    @EnvironmentObject var interventionHandler: InterventionHandler

    @State var state: LayoutState = .initial
    var scope: TimelineSplitViewModel.TimelineType

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
                    EmptyView()
                }
                    .animation(.easeInOut, value: model.timelineData)
                    .navigationDestination(for: Status.self) { status in
                        StatusDetailView(status: status, level: .parent)
                    }
            case .errored(let message):
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("\(message)")
                    Button {
                        Task {
                            state = .loading
                            state = await model.loadTimeline(
                                policy: .refreshEntireContents,
                                using: interventionHandler
                            )
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
                    state = await model.loadTimeline(
                        policy: .refreshEntireContents,
                        using: interventionHandler
                    )
                }
            }
        }
        .onChange(of: scope) { newValue in
            model.scope = newValue
            state = .initial
            Task {
                state = await model.loadTimeline(
                    forcefully: true,
                    policy: .refreshEntireContents
                )
            }
        }
        .refreshable {
            withAnimation {
                state = .loading
                Task {
                    state = await model.loadTimeline(
                        forcefully: true,
                        policy: .refreshEntireContents,
                        using: interventionHandler
                    )
                }
            }
        }
        .alert("interventions.missing.title", isPresented: $model.displayOneSecNotInstalledWarning) {
            Button {
                if let url = URL(
                    string: "https://apps.apple.com/app/apple-store/id1532875441?pt=120233067&ct=fedigardens"
                ) {
                    openURL(url)
                }
            } label: {
                Text("interventions.cta.install")
            }
            Button {
                UserDefaults.standard.allowsInterventions = false
            } label: {
                Text("interventions.cta.disable")
            }
            Button {

            } label: {
                Text("interventions.cta.dismiss")
            }.keyboardShortcut(.defaultAction)
        } message: {
            Text("interventions.missing.detail")
        }
    }

    private var loadNextButton: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    state = .loading
                    Task {
                        state = await model.loadTimeline(
                            forcefully: true,
                            policy: .preloadNextBatch,
                            using: interventionHandler
                        )
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
