//
//  CompactLayout.swift
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

// MARK: - Compact Layout

/// A view that represents the layout for compact devices.
/// This is commonly used on iOS devices such as iPhone.
struct CompactLayout: View {
    var body: some View {
        TabView {
            NavigationView {
                CompactTimeline(timeline: .home)
                    .navigationTitle("endpoint.home")
                    .padding()
            }
            .tabItem {
                Label("endpoint.home", systemImage: "house")
            }
            NavigationView {
                CompactTimeline(timeline: .network)
                    .navigationTitle("endpoint.local")
                    .padding()
            }
            .tabItem {
                Label("endpoint.local", systemImage: "star")
            }
            NavigationView {
                MessagingList()
                    .listStyle(.plain)
                    .navigationTitle("endpoint.directmessage")
            }.tabItem {
                Label("endpoint.directmessage", systemImage: "bubble.left.and.bubble.right")
            }
            NavigationView {
                SettingsView()
                    .navigationTitle("general.settings")
            }.tabItem {
                Label("general.settings", systemImage: "gear")
            }
        }
    }
}

// MARK: - Previews

struct CompactLayout_Previews: PreviewProvider {
    static var previews: some View {
        CompactLayout()
            .previewDevice("iPhone 13 Pro")
    }
}
