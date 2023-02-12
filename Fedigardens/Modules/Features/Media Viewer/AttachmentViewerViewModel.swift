//
//  AttachmentViewerViewModel.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/5/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Combine
import Alice

class AttachmentViewerViewModel: ObservableObject {
    @Published var attachments = [MediaAttachment]()
    @Published var contentMode = ContentMode.fit
    @Published var currentAttachment: MediaAttachment?
    @Published var didAcknowledgeConsent = false
    @Published var magnification = 1.0
    @Published var shouldDisplayConsentAcknowledgementAlert = false

    func toggleContentMode() {
        contentMode = (contentMode == .fit) ? .fill : .fit
    }

    func systemImageForContentMode() -> String {
        switch contentMode {
        case .fill:
            return "arrow.down.right.and.arrow.up.left"
        case .fit:
            return "arrow.up.left.and.arrow.down.right"
        }
    }
}
