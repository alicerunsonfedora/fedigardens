//
//  StatusMediaDrawer.swift
//  Gardens
//
//  Created by Marquis Kurt on 12/24/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Chica
import AVKit

struct StatusMediaDrawer: View {
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
                Group {
                    switch attachment.type {
                    case .image:
                        image(of: attachment)
                    case .video, .gifv:
                        VideoPlayer(player: videoPlayer(for: attachment.url)) {
                            VStack {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .imageScale(.large)
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                Spacer()
                            }.padding()
                        }
                            .aspectRatio(3/2, contentMode: .fill)
                    default:
                        Label("Unidentified attachments", systemImage: "questionmark.circle")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .bold()
                    }
                }
            }
        }
        .padding(.vertical)
    }

    private func image(of attachment: Attachment) -> some View {
        AsyncImage(url: .init(string: attachment.url)!) { image in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                image
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(3/2, contentMode: .fill)
            }
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.5))
                )
        } placeholder: {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.2))
                .aspectRatio(3/2, contentMode: .fill)
        }
    }

    private func videoPlayer(for resource: String) -> AVPlayer? {
        guard let url = URL(string: resource) else { return nil }
        return AVPlayer(url: url)
    }
}
