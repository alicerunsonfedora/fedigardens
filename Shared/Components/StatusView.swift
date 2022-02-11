// 
//  StatusView.swift
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


struct StatusView: View {
    @State var status: Status
    @State var truncateLines: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "person.circle")
                    .imageScale(.large)
                VStack {
                    HStack {
                        Text(status.account.displayName)
                            .bold()
                        Text("(@\(status.account.acct))")
                            .foregroundColor(.secondary)
                    }
                    .font(.system(.title3, design: .rounded))
                }
            }
            Text(status.content.toPlainText())
                .lineLimit(truncateLines)
            HStack {
                Spacer()
                Text(status.createdAt)
                    .foregroundColor(.secondary)
            }
        }
        .font(.system(.body, design: .rounded))
        .padding()
    }
}

struct StatusView_Previews: PreviewProvider {
    static var statusData: Status? = try! JSONDecoder.decodeFromResource(from: "Status")

    static var previews: some View {
        Group {

            StatusView(status: statusData!)
                .frame(maxWidth: 550)

            List {
                ForEach(1..<5) { _ in
                    StatusView(status: statusData!, truncateLines: 2)
                }
            }
            .frame(maxWidth: 400)
        }

    }
}
