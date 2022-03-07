//
//  StatusListMDView.swift
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

import Chica
import Foundation
import SwiftUI

// MARK: - Status List Master-Detail View

/// A view used to display a list of statuses in a master-detail view.
/// This is commonly used on iPadOS and macOS to show statuses on the left, and their context page on the right.
struct StatusListMDView: View {
    /// The list of statuses to render in the master-detail view.
    @State var statuses: [Status]

    var body: some View {
        List(statuses, id: \.id) { status in
            NavigationLink {
                StatusDetailView(status: status)
                    .frame(minWidth: 300, idealWidth: 400)
            } label: {
                StatusView(status: status)
                    .lineLimit(2)
                    .profilePlacement(.hidden)
                    .datePlacement(.automatic)
                    .profileImageSize(44)
                    .padding(4)
                    .padding(.leading, 12)
            }
        }
        .frame(minWidth: 350, idealWidth: 400)
    }
}

// MARK: - Previews

struct StatusListMDView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatusListMDView(statuses: MockData.timeline!)
        }
        .frame(minWidth: 700)
    }
}
