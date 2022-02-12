// 
//  StatusListScrollView.swift
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

import Foundation
import SwiftUI
import Chica

struct StatusListScrollView: View {

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
