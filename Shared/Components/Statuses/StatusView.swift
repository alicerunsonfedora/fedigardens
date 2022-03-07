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

import Chica
import Foundation
import SwiftUI

// MARK: - Status View

/// A view that displays a status created by a user.
struct StatusView: View {
    /// An enumeration representing the different position options for the status creation date.
    public enum DatePlacement {
        /// Automatically determine the position of the date in the view.
        ///
        /// If there is no line limit for the status content, it is placed below the status content, right-aligned.
        /// Otherwise, it is placed above, across from the author's username.
        case automatic

        /// Under the author's username, before the status's content.
        case underUsername

        /// Under the status content.
        case underContent
    }

    /// An enumeration representing the different position options for the author's profile image.
    public enum ProfileImagePlacement {
        /// Next to the author's name, towards the left side.
        case byAuthorName

        /// Next to the entire view on the left side.
        ///
        /// Ideal for messages and list entries in a master-detail view.
        case byEntireView

        /// The profile image is completely hidden from view.
        ///
        /// Ideal for messages and list entries in a master-detail view, where space is limited.
        case hidden
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

    /// The square size of the author's profile image.
    @State fileprivate var profileImageSize: CGFloat

    /// Whether to show like and boot statistics.
    @State fileprivate var showStatistics: Bool

    /// The content of the status.
    ///
    /// While it is possible to access the status's content via `Status.content.toPlainText()`, this method must be
    /// performed asynchronously, as the HTML renderer does not work in a background thread.
    @State private var renderedContent: String = "status"

    init(status: Status) {
        self.init(
            status: status,
            truncateLines: nil,
            datePlacement: .automatic,
            profileImagePlacement: .byAuthorName,
            profileImageSize: 48,
            showStatistics: false
        )
    }

    fileprivate init(
        status: Status,
        truncateLines: Int?,
        datePlacement: DatePlacement,
        profileImagePlacement: ProfileImagePlacement,
        profileImageSize: CGFloat,
        showStatistics: Bool
    ) {
        self.status = status
        self.truncateLines = truncateLines
        self.datePlacement = datePlacement
        self.profileImagePlacement = profileImagePlacement
        self.profileImageSize = profileImageSize
        self.showStatistics = showStatistics
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
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(status.account.displayName)
                                    .font(.system(.callout, design: .rounded))
                                    .bold()
                                Text("(@\(status.account.acct))")
                                    .foregroundColor(.secondary)
                                    .font(.system(.callout, design: .rounded))
                            }
                            if datePlacement == .automatic, truncateLines != nil {
                                Spacer()
                                statusCreationDate
                            }
                        }
                        .font(.system(.title3, design: .rounded))
                        if datePlacement == .underUsername {
                            statusCreationDate
                        }
                    }
                }
                Text(renderedContent)
                    .lineLimit(truncateLines)
                if showStatistics {
                    HStack(spacing: 16) {
                        Label("\(status.favouritesCount)", systemImage: "star")
                        Label("\(status.reblogsCount)", systemImage: "arrow.2.squarepath")
                        Label("\(status.repliesCount)", systemImage: "text.bubble")
                    }
                    .foregroundColor(.secondary)
                    .font(.system(.callout))
                    .padding(.top, 8)
                }
                if (datePlacement == .automatic && truncateLines == nil) || datePlacement == .underContent {
                    HStack {
                        Spacer()
                        statusCreationDate
                    }
                }
            }
        }
        .font(.system(.body, design: .rounded))
        .onAppear {
            Task {
                renderedContent = await status.content.toPlainText()
            }
        }
    }

    private var statusCreationDate: some View {
        Text(
            DateFormatter.mastodon.date(from: status.createdAt)!,
            format: .relative(presentation: .named)
        )
        .foregroundColor(.secondary)
        .font(.system(.footnote, design: .rounded))
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
        .frame(width: profileImageSize, height: profileImageSize)
    }
}

// MARK: - Modifiers

extension StatusView {
    /// Sets the maximum number of lines to display the status's content at.
    func lineLimit(_ lineLimit: Int) -> StatusView {
        StatusView(
            status: status,
            truncateLines: lineLimit,
            datePlacement: datePlacement,
            profileImagePlacement:
            profileImagePlacement,
            profileImageSize: profileImageSize,
            showStatistics: showStatistics
        )
    }

    /// Sets the placement for where the author's profile image will appear.
    func profilePlacement(_ profilePlacement: ProfileImagePlacement) -> StatusView {
        StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profilePlacement,
            profileImageSize: profileImageSize,
            showStatistics: showStatistics
        )
    }

    func profileImageSize(_ profileSize: CGFloat) -> StatusView {
        StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileSize,
            showStatistics: showStatistics
        )
    }

    /// Sets the placement for where the status's creation date will appear.
    func datePlacement(_ datePlacement: DatePlacement) -> StatusView {
        StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileImageSize,
            showStatistics: showStatistics
        )
    }

    /// Whether to show the likes and boosts for this status.
    func statistics(_ show: Bool) -> StatusView {
        StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileImageSize,
            showStatistics: show
        )
    }
}

// MARK: - Previews

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusView(status: MockData.status!)
                .datePlacement(.underUsername)
                .statistics(true)
                .padding()
                .frame(maxWidth: 550)

            List {
                ForEach(1 ..< 5) { _ in
                    StatusView(status: MockData.status!)
                        .lineLimit(2)
                        .profilePlacement(.byEntireView)
                        .datePlacement(.automatic)
                }
            }
            .frame(maxWidth: 400)
        }
    }
}
