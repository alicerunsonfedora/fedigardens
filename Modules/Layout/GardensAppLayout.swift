//
//  GardensAppLayout.swift
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

struct GardensAppLayout: View {
    /// An enumeration representing the various pages in the app.
    private enum PageSelection: Hashable {
        /// The "For You" page, which displays the home timeline.
        case forYou

        /// The "Community" page, which displays the local timeline.
        case local

        /// The "Latest" page, which displays the public timeline.
        case `public`

        /// The "Messages" page, which displays direct messages.
        case messages

        /// The "Your Posts" page, which displays posts created by the user.
        case selfPosts

        /// The "Notifications" page, which displays notifications.
        case notifications

        case trending(id: String)

        /// The Settings page (iOS-only).
        case settings
    }

    @Environment(\.userProfile) var userProfile: Account

    /// The dummy timeline data used to render certain components.
    @State private var dummyTimeline: [Status]? = MockData.timeline

    /// The current selected page.
    @State private var currentPage: PageSelection? = .forYou

    @State private var selectedStatus: Status?

    @State private var tags: [Tag] = []

    var body: some View {
        NavigationSplitView {
            List(selection: $currentPage) {
                NavigationLink(value: PageSelection.forYou) {
                    Label("endpoint.home", systemImage: "house")
                }
                NavigationLink(value: PageSelection.local) {
                    Label("endpoint.local", systemImage: "building.2")
                }
                NavigationLink(value: PageSelection.public) {
                    Label("endpoint.latest", systemImage: "sparkles")
                }
                NavigationLink(value: PageSelection.messages) {
                    Label("endpoint.directmessage", systemImage: "bubble.left.and.bubble.right")
                }
                NavigationLink(value: PageSelection.selfPosts) {
                    Label {
                        Text("endpoint.selfposts")
                    } icon: {
                        AccountImage(author: userProfile)
                            .profileSize(.medium)
                    }
                }
                NavigationLink(value: PageSelection.settings) {
                    Label("general.settings", systemImage: "gear")
                }

                Section {
                    ForEach(tags) { tag in
                        NavigationLink(value: PageSelection.trending(id: tag.name)) {
                            Label(tag.name, systemImage: "tag")
                        }
                    }
                } header: {
                    Text("endpoint.trending")
                }

            }
            .navigationTitle("general.appname")
            .listStyle(.sidebar)
        } content: {
            sidebarContent
                .toolbar {
                    ToolbarItem {
                        GardensComposeButton()
                    }
                }
        } detail: {
            if let selectedStatus {
                StatusDetailView(status: selectedStatus, level: .parent)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "quote.bubble")
                    Text("general.nopost")
                }
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            Task { await fetchTags() }
        }
    }

    private var sidebarContent: some View {
        Group {
            if let destination = currentPage {
                Group {
                    switch destination {
                    case .forYou:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .home, local: false),
                            selectedStatus: $selectedStatus
                        )
                            .navigationTitle("endpoint.home")
                    case .local:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .network, local: true),
                            selectedStatus: $selectedStatus
                        )
                            .navigationTitle("endpoint.local")
                    case .public:
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .network, local: false),
                            selectedStatus: $selectedStatus
                        )
                        .navigationTitle("endpoint.latest")
                    case .messages:
                        MessagingList()
                            .navigationTitle("endpoint.directmessage")
                    case .selfPosts:
                        TimelineSplitView(
                            scope: .profile(id: userProfile.id),
                            selectedStatus: $selectedStatus
                        )
                        .navigationTitle("endpoint.selfposts")
                    case .trending(let id):
                        TimelineSplitView(
                            scope: .scopedTimeline(scope: .tag(tag: id), local: false),
                            selectedStatus: $selectedStatus
                        )
                        .navigationTitle("#\(id)")
                    case .settings:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                    Text("general.nopage")
                }
                .font(.system(.largeTitle, design: .rounded))
                .foregroundColor(.secondary)
            }
        }
    }

    private func fetchTags() async {
        let response: Chica.Response<[Tag]> = await Chica.shared.request(.get, for: .trending)
        switch response {
        case .success(let tags):
            self.tags = tags
        case .failure(let error):
            print("Tag fetch error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Previews

struct WidescreenLayout_Previews: PreviewProvider {
    static var previews: some View {
        GardensAppLayout()
            .frame(minWidth: 900, minHeight: 500)
    }
}
