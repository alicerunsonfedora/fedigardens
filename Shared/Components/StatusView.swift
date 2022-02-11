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

// MARK: - Status View

/// A view that displays a status created by a user.
struct StatusView: View {

    /// An enumeration representing the different position options for the status creation date.
    enum DatePlacement {

        /// The default position. Typically, this appears as the last line, under the status's content.
        case `default`

        /// Under the author's username, before the status's content.
        case underUsername
    }

    /// An enumeration representing the different position options for the author's profile image.
    enum ProfileImagePlacement {

        /// Next to the author's name, towards the left side.
        case byAuthorName

        /// Next to the entire view on the left side.
        ///
        /// Ideal for messages and list entries in a master-detail view.
        case byEntireView
    }

    /// The status data to render in this view.
    @State var status: Status

    /// The maximum number of lines to display in the status's content.
    ///
    /// If this value is `nil`, all lines will be displayed.
    @State fileprivate var truncateLines: Int?

    /// The placement configuration for the date.
    @State fileprivate var datePlacement: DatePlacement

    /// The placement configuration for the author's profile image.
    @State fileprivate var profileImagePlacement: ProfileImagePlacement

    init(status: Status) {
        self.init(status: status, truncateLines: nil, datePlacement: .default, profileImagePlacement: .byAuthorName)
    }

    fileprivate init(
        status: Status,
        truncateLines: Int?,
        datePlacement: DatePlacement,
        profileImagePlacement: ProfileImagePlacement
    ) {
        self.status = status
        self.truncateLines = truncateLines
        self.datePlacement = datePlacement
        self.profileImagePlacement = profileImagePlacement
    }

    var body: some View {
        HStack(spacing: 16) {
            if profileImagePlacement == .byEntireView {
                authorImage
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if profileImagePlacement == .byAuthorName {
                        authorImage
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text(status.account.displayName)
                                .bold()
                            Text("(@\(status.account.acct))")
                                .foregroundColor(.secondary)
                        }
                        .font(.system(.title3, design: .rounded))
                        if datePlacement == .underUsername {
                            statusCreationDate
                        }
                    }
                }
                Text(status.content.toPlainText())
                    .lineLimit(truncateLines)
                if datePlacement == .default {
                    HStack {
                        Spacer()
                        statusCreationDate
                    }
                }
            }
        }
        .font(.system(.body, design: .rounded))
    }

    private var statusCreationDate: some View {
        Text(
            DateFormatter.mastodon.date(from: status.createdAt)!,
            format: .relative(presentation: .named)
        )
            .foregroundColor(.secondary)
    }

    private var authorImage: some View {
        AsyncImage(url: .init(string: status.account.avatarStatic)) { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
        } placeholder: {
            Image(systemName: "person.circle")
                .imageScale(.large)
        }
        .frame(width: 48, height: 48)
    }
}

// MARK: - Modifiers

extension StatusView {

    /// Sets the maximum number of lines to display the status's content at.
    func lineLimit(_ lineLimit: Int) -> StatusView {
        StatusView(
            status: self.status,
            truncateLines: lineLimit,
            datePlacement: self.datePlacement,
            profileImagePlacement:
                self.profileImagePlacement
        )
    }

    /// Sets the placement for where the author's profile image will appear.
    func profilePlacement(_ profilePlacement: ProfileImagePlacement) -> StatusView {
        StatusView(
            status: self.status,
            truncateLines: self.truncateLines,
            datePlacement: self.datePlacement,
            profileImagePlacement: profilePlacement
        )
    }

    /// Sets the placement for where the status's creation date will appear.
    func datePlacement(_ datePlacement: DatePlacement) -> StatusView {
        StatusView(
            status: self.status,
            truncateLines: self.truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: self.profileImagePlacement
        )
    }
}

// MARK: - Previews
struct StatusView_Previews: PreviewProvider {
    static var statusData: Status? = try! JSONDecoder.decodeFromResource(from: "Status")

    static var previews: some View {
        Group {

            StatusView(status: statusData!)
                .datePlacement(.underUsername)
                .padding()
                .frame(maxWidth: 550)

            List {
                ForEach(1..<5) { _ in
                    StatusView(status: statusData!)
                        .lineLimit(2)
                        .profilePlacement(.byEntireView)
                        .datePlacement(.default)
                }
            }
            .frame(maxWidth: 400)
        }

    }
}
