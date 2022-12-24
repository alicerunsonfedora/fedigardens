//
//  WidescreenLayout.swift
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

        /// The Settings page (iOS-only).
        case settings
    }

    /// The dummy timeline data used to render certain components.
    @State private var dummyTimeline: [Status]? = MockData.timeline

    /// The current selected page.
    @State private var currentPage: PageSelection? = .forYou

    var body: some View {
        NavigationView {
            List(selection: $currentPage) {
                Section {
                    NavigationLink(tag: PageSelection.forYou, selection: $currentPage) {
                        WidescreenTimeline(timeline: .home)
                            .navigationTitle("endpoint.home")
                    } label: {
                        Label("endpoint.home", systemImage: "house")
                    }
                    NavigationLink(tag: PageSelection.latest, selection: $currentPage) {
                        WidescreenTimeline(timeline: .network)
                            .navigationTitle("endpoint.local")
                    } label: {
                        Label("endpoint.local", systemImage: "star")
                    }
                    NavigationLink(tag: PageSelection.messages, selection: $currentPage) {
                        MessagingList()
                            .navigationTitle("endpoint.directmessage")
                    } label: {
                        Label("endpoint.directmessage", systemImage: "bubble.left.and.bubble.right")
                    }
                    NavigationLink(tag: PageSelection.settings, selection: $currentPage) {
                        SettingsView()
                            .navigationViewStyle(.stack)
                    } label: {
                        Label("general.settings", systemImage: "gear")
                    }
                } header: {
                    Text("Quick Places")
                }
            }
            .frame(minWidth: 225, idealWidth: 275)
            .navigationTitle("general.appname")
            
            EmptyView()
            VStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle")
                Text("general.nopage")
            }
            .font(.system(.largeTitle, design: .rounded))
            .foregroundColor(.secondary)
        }
        .onAppear {
            self.currentPage = .forYou
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
