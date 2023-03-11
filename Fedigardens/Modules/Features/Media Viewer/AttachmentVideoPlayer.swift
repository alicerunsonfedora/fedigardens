//
//  AttachmentVideoPlayer.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 3/11/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import UIKit
import AVKit

struct AttachmentVideoPlayer: UIViewControllerRepresentable {
    typealias UIViewControllerType = AVPlayerViewController
    var player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.videoGravity = .resizeAspect
        controller.showsTimecodes = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
