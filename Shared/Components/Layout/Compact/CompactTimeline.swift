//
//  CompactTimeline.swift
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

/// A view used to render a timeline in the compact layout.
struct CompactTimeline: View, LayoutStateRepresentable {
    /// The timeline scope to render into view.
    @State var timeline: TimelineScope

    /// The data fetched from the specified timeline.
    @State private var timelineData: [Status]? = []

    /// A dummy timeline dataset used to render statuses into view.
    @State private var dummyTimeline: [Status]? = MockData.timeline

    /// Whether the author view should be displayed as a sheet on iOS.
    ///
    /// Defaults to `false`, and is only marked `true` in iOS by a button press.
    @State private var composeStatus: Bool = false

    /// The internal state of the view.
    @State var state: LayoutState = .initial

    var body: some View {
        ScrollView {
            Group {
                switch state {
                case .initial, .loading:
                    StatusListScrollView(statuses: dummyTimeline!)
                        .redacted(reason: .placeholder)
                case .loaded:
                    StatusListScrollView(statuses: timelineData ?? [])
                case .errored(let message):
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("\(message)")
                }
            }
        }
        .onAppear {
            Task {
                await loadTimeline()
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    composeStatus.toggle()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .help("help.poststatus")
            }
            ToolbarItem {
                Button {
                    Task { await loadTimeline(forcefully: true) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("help.refresh")
            }
        }
        .sheet(isPresented: $composeStatus) {
            NavigationView {
                AuthorView()
            }
#if os(iOS)
            .navigationViewStyle(.stack)
#endif
        }
    }

    /// Load the timeline into the view.
    /// - Parameter forcefully: Whether to forcefully reload the data, regardless if the timeline is already loaded.
    ///     Defaults to false.
    ///
    /// Typically, this method is called when rendering the view for the first time to fetch the timeline contents.
    /// Since the network call is asynchronous, this method has been made asynchronous.
    ///
    /// - Important: Only forcefully reload data when the user requests it. This call may be expensive on the network
    ///     and may take time to re-fetch the data into memory.
    func loadTimeline(forcefully: Bool = false) async {
        if !forcefully, timelineData?.isEmpty == false {
            return
        }
        state = .loading
        do {
            timelineData = try await Chica.shared.request(
                .get,
                for: .timeline(scope: timeline),
                params: ["limit": "7"]
            )
            state = .loaded
        } catch {
            print(error)
            state = .errored(message: error.localizedDescription)
        }
    }
}
