// 
//  WidescreenLayout.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 11/2/22.
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

// MARK: - Widescreen Layout

/// A view that represents the widescreen layout.
/// This is commonly used on wider devices such as iPad or Mac.
struct WidescreenLayout: View {

    /// An enumeration representing the various pages in the app.
    private enum PageSelection {

        /// The "For You" page, which displays the home timeline.
        case forYou

        /// The "Latest" page, which displays the local timeline.
        case latest

        /// The "Messages" page, which displays direct messages.
        case messages

        /// The "Notifications" page, which displays notifications.
        case notifications
    }

    /// The dummy timeline data used to render certain components.
    @State private var dummyTimeline: [Status]? = MockData.timeline

    /// The current selected page.
    @State private var currentPage: PageSelection? = .forYou

    var body: some View {
        NavigationView {
            List(selection: $currentPage) {
                Section {
                    NavigationLink {
                        WidescreenTimeline(timeline: .home)
                            .navigationTitle("endpoint.home")
                    } label: {
                        Label("endpoint.home", systemImage: "house")
                    }
                    .tag(PageSelection.forYou)
                    NavigationLink {
                        WidescreenTimeline(timeline: .network)
                            .navigationTitle("endpoint.local")
                    } label: {
                        Label("endpoint.local", systemImage: "star")
                    }
                    .tag(PageSelection.latest)
                } header: {
                    Text("Quick Places")
                }
            }
            .frame(minWidth: 175, idealWidth: 225)
            .navigationTitle("general.appname")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Button {
                        NSApp.keyWindow?.firstResponder?.tryToPerform(
                            #selector(NSSplitViewController.toggleSidebar(_:)),
                            with: nil
                        )
                    } label: {
                        Label("general.togglesidebar", systemImage: "sidebar.left")
                    }
                }
#endif
            }

            EmptyView()
            EmptyView()

        }
    }
}

// MARK: - Previews
struct WidescreenLayout_Previews: PreviewProvider {
    static var previews: some View {
        WidescreenLayout()
            .frame(minWidth: 900, minHeight: 500)
    }
}
