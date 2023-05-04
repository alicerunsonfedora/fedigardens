//
//  StatusAttachmentAlternative.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 5/4/23.
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

struct StatusAttachmentAlernative: View {
    var attachment: MediaAttachment
    var body: some View {
        Label(attachment.description ?? "attachments.description.missing".localized(), systemImage: symbol)
    }

    var symbol: String {
        switch attachment.type {
        case .audio:
            return "speaker.wave.2.fill"
        case .gifv, .video:
            return "film"
        case .image:
            return "photo"
        case .unknown:
            return "questionmark.app.dashed"
        }
    }
}

struct StatusAttachmentAlernative_Previews: PreviewProvider {
    static let attachments: [MediaAttachment] = MockData.status!.mediaAttachments
    static var previews: some View {
        ForEach(attachments) { attachment in
            StatusAttachmentAlernative(attachment: attachment)
        }
    }
}
