//
//  StatusListScrollView.swift
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

// MARK: - Status List (Scroll View)

/// A view that displays a list of statuses in a ScrollView.
///
/// Typically, this is used on iOS to display a list of statuses witout rendering the list lines.
struct StatusListScrollView: View {
    /// The list of statuses that will be rendered in the view.
    @State var statuses: [Status]

    var body: some View {
        VStack {
            ForEach(statuses, id: \.id) { status in
                NavigationLink {
                    StatusDetailView(status: status)
                } label: {
                    StatusView(status: status)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Previews

struct StatusListScrollView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollView {
                StatusListScrollView(statuses: MockData.timeline!)
                    .previewDevice("iPhone 13 Pro")
                    .navigationTitle("Timeline")
            }
        }
    }
}
