//
//  StatusMediaDrawer.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Alice
import AVKit

struct AttachmentMediaGroup: View {
    var status: Status

    private var mediaAttachments: [Attachment] {
        status.reblog?.mediaAttachments ?? status.mediaAttachments
    }

    private var columns: [GridItem] {
        if mediaAttachments.count > 1 { return [GridItem(.flexible()), GridItem(.flexible())] }
        return [GridItem(.flexible())]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(mediaAttachments) { (attachment: Attachment) in
                AttachmentMedia(attachment: attachment)
            }
        }
        .padding(.vertical)
    }
}

struct AttachmentMediaGroup_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StatusView(status: MockData.status!)
                .lineLimit(6)
                .redacted(reason: .privacy)
            AttachmentMediaGroup(status: MockData.status!)
            Spacer()
        }
        .padding()
    }
}
