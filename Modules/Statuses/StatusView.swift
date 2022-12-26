//
//  StatusView.swift
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

// MARK: - Status View

struct StatusView: View {
    public enum DatePlacement {
        case automatic
        case underUsername
        case underContent
    }

    public enum ProfileImagePlacement {
        case byAuthorName
        case byEntireView
        case hidden
    }

    public enum ReblogNoticePlacement {
        case underContent
        case aboveContent
        case aboveOriginalAuthor
        case hidden
    }

    @AppStorage("status.show-statistics") var showsStatistics: Bool = true

    var status: Status

    @State fileprivate var truncateLines: Int?
    @State fileprivate var datePlacement: DatePlacement
    @State fileprivate var profileImagePlacement: ProfileImagePlacement
    @State fileprivate var profileImageSize: CGFloat
    @State fileprivate var reblogNoticePlacement: ReblogNoticePlacement
    @State fileprivate var verifiedNoticePlacement: StatusAuthorExtendedLabel.VerificationPlacementPolicy
    
    fileprivate var displayDisclosedContent: Bool

    init(status: Status) {
        self.init(
            status: status,
            truncateLines: nil,
            datePlacement: .automatic,
            profileImagePlacement: .byAuthorName,
            profileImageSize: 48,
            reblogNoticePlacement: .underContent,
            displayDisclosedContent: status.spoilerText.isEmpty,
            verifiedNoticePlacement: .hidden
        )
    }

    fileprivate init(
        status: Status,
        truncateLines: Int?,
        datePlacement: DatePlacement,
        profileImagePlacement: ProfileImagePlacement,
        profileImageSize: CGFloat,
        reblogNoticePlacement: ReblogNoticePlacement,
        displayDisclosedContent: Bool,
        verifiedNoticePlacement: StatusAuthorExtendedLabel.VerificationPlacementPolicy
    ) {
        self.status = status
        self.truncateLines = truncateLines
        self.datePlacement = datePlacement
        self.profileImagePlacement = profileImagePlacement
        self.profileImageSize = profileImageSize
        self.reblogNoticePlacement = reblogNoticePlacement
        self.displayDisclosedContent = displayDisclosedContent
        self.verifiedNoticePlacement = verifiedNoticePlacement
    }

    var body: some View {
        HStack(spacing: 16) {
            if profileImagePlacement == .byEntireView {
                authorImage
            }
            VStack(alignment: .leading, spacing: truncateLines != nil ? 4 : 8) {
                if reblogNoticePlacement == .aboveOriginalAuthor, status.reblog != nil {
                    reblogNotice
                        .font(.subheadline)
                        .padding(.vertical, 8)
                }
                HStack {
                    if profileImagePlacement == .byAuthorName { authorImage }
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            StatusAuthorExtendedLabel(status: status, placementPolicy: verifiedNoticePlacement)
                            if truncateLines != nil {
                                if datePlacement == .automatic {
                                    Spacer()
                                    if !status.mediaAttachments.isEmpty || (
                                        !(status.reblog?.mediaAttachments.isEmpty ?? true)
                                    ) {
                                        Image(systemName: "paperclip")
                                            .foregroundColor(.secondary)
                                            .font(.footnote)
                                    }
                                    statusCreationDate
                                }
                            }

                        }
                        .font(.system(.title3, design: .rounded))
                        if datePlacement == .underUsername {
                            if !status.mediaAttachments.isEmpty || (
                                !(status.reblog?.mediaAttachments.isEmpty ?? true)
                            ) {
                                Image(systemName: "paperclip")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                            statusCreationDate
                        }
                    }
                }
                if reblogNoticePlacement == .aboveContent, status.reblog != nil {
                    reblogNotice
                        .font(.subheadline)
                        .padding(.vertical, 8)
                }

                StatusDisclosedContent(
                    discloseContent: displayDisclosedContent,
                    status: status,
                    truncateLines: truncateLines
                )

                if showsStatistics, truncateLines == nil {
                    HStack(spacing: 10) {
                        Label("\(status.favouritesCount)", systemImage: "star")
                        Label("\(status.reblogsCount)", systemImage: "arrow.2.squarepath")
                    }
                    .foregroundColor(.secondary)
                    .font(.callout)
                }
                if (datePlacement == .automatic && truncateLines == nil) || datePlacement == .underContent {
                    HStack {
                        if reblogNoticePlacement == .underContent, status.reblog != nil {
                            reblogNotice
                                .font(.footnote)
                        }
                        Spacer()
                        statusCreationDate
                    }
                    .padding(.top, 8)
                } else if reblogNoticePlacement == .underContent, status.reblog != nil {
                    reblogNotice
                        .font(.footnote)
                        .padding(.top, 8)
                }
            }
        }
        .font(.system(.body, design: .rounded))
        .privacySensitive()
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
        AsyncImage(url: .init(string: status.reblog?.account.avatarStatic ?? status.account.avatarStatic)) { image in
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

    private var reblogNotice: some View {
        Label {
            Text("\(status.account.getAccountName()) reblogged")
                .bold()
        } icon: {
            AccountImage(author: status.account)
                .profileSize(.small)
        }
        .foregroundColor(.secondary)
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
            reblogNoticePlacement: reblogNoticePlacement,
            displayDisclosedContent: displayDisclosedContent,
            verifiedNoticePlacement: verifiedNoticePlacement
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
            reblogNoticePlacement: reblogNoticePlacement,
            displayDisclosedContent: displayDisclosedContent,
            verifiedNoticePlacement: verifiedNoticePlacement
        )
    }

    func profileImageSize(_ profileSize: CGFloat) -> StatusView {
        StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileSize,
            reblogNoticePlacement: reblogNoticePlacement,
            displayDisclosedContent: displayDisclosedContent,
            verifiedNoticePlacement: verifiedNoticePlacement
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
            reblogNoticePlacement: reblogNoticePlacement,
            displayDisclosedContent: displayDisclosedContent,
            verifiedNoticePlacement: verifiedNoticePlacement
        )
    }

    /// Whether to show the likes and boosts for this status.
    @available(*, deprecated, message: "This method is no longer supported and will be removed in a future release.")
    func statistics(_ show: Binding<Bool>) -> StatusView {
        StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileImageSize,
            reblogNoticePlacement: reblogNoticePlacement,
            displayDisclosedContent: displayDisclosedContent,
            verifiedNoticePlacement: verifiedNoticePlacement
        )
    }

    func reblogNoticePlacement(_ placement: ReblogNoticePlacement) -> StatusView {
        StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileImageSize,
            reblogNoticePlacement: placement,
            displayDisclosedContent: displayDisclosedContent,
            verifiedNoticePlacement: verifiedNoticePlacement
        )
    }

    func showsDisclosedContent(_ disclosure: Binding<Bool>) -> StatusView {
        return StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileImageSize,
            reblogNoticePlacement: reblogNoticePlacement,
            displayDisclosedContent: disclosure.wrappedValue,
            verifiedNoticePlacement: verifiedNoticePlacement
        )
    }

    func verifiedNoticePlacement(_ policy: StatusAuthorExtendedLabel.VerificationPlacementPolicy) -> StatusView {
        return StatusView(
            status: status,
            truncateLines: truncateLines,
            datePlacement: datePlacement,
            profileImagePlacement: profileImagePlacement,
            profileImageSize: profileImageSize,
            reblogNoticePlacement: reblogNoticePlacement,
            displayDisclosedContent: displayDisclosedContent,
            verifiedNoticePlacement: policy
        )
    }
}

// MARK: - Previews

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusView(status: MockData.status!)
                .datePlacement(.underUsername)
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
