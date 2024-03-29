//
//  AttachmentViewer.swift
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

import Alice
import SeedUI
import SwiftUI

struct AttachmentViewer: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AttachmentViewerViewModel()

    var attachments: [MediaAttachment]

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { changedValue in
                withAnimation {
                    viewModel.magnification = changedValue
                }
            }
            .onEnded { finalValue in
                withAnimation {
                    viewModel.magnification = max(1.0, finalValue)
                }
            }
    }

    var body: some View {
        NavigationStack {
            Group {
                if attachments.isEmpty {
                    emptyView
                } else {
                    viewer
                }
            }
        }
        .animation(.spring(), value: viewModel.contentMode)
        .onAppear {
            viewModel.attachments = attachments
        }
    }

    private var emptyView: some View {
        VStack {
            Image(systemName: "paperclip")
                .font(.largeTitle)
                .imageScale(.large)
            Text("attachments.empty.warning")
                .font(.title2)
                .bold()
        }
        .foregroundColor(.secondary)
        .toolbar {
            ToolbarItem {
                Button(action: dismiss.callAsFunction) {
                    Text("general.done")
                        .bold()
                }
            }
        }
    }

    private var viewer: some View {
        TabView {
            ForEach(attachments, id: \.id) { attachment in
                VStack {
                    AttachmentMedia(attachment: attachment)
                        .aspectRatio(contentMode: viewModel.contentMode)
                        .scaleEffect(viewModel.magnification)
                        .gesture(zoomGesture)
                }
                .padding()
                .onAppear {
                    withAnimation(.easeInOut) {
                        viewModel.currentAttachment = attachment
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
        .tabViewStyle(.page)
        .background(
            Group {
                if let attachment = viewModel.currentAttachment {
                    preview(for: attachment)
                } else {
                    Color.black
                }
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Group {
                if let attachment = viewModel.currentAttachment {
                    Text(attachment.description ?? "attachments.description.missing".localized())
                        .font(.footnote)
                }
            }
            .padding()
        }
        .giantAlert(
            isPresented: $viewModel.shouldDisplayConsentAcknowledgementAlert,
            title: "attachments.share.title"
        ) {
            Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
        } actions: {
            Button {
                viewModel.didAcknowledgeConsent = true
                viewModel.shouldDisplayConsentAcknowledgementAlert = false
            } label: {
                Text("attachments.share.acknowledge")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            Button(role: .cancel) {
                viewModel.shouldDisplayConsentAcknowledgementAlert = false
            } label: {
                Text("attachments.share.cancel")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        } message: {
            Text("attachments.share.detail")
        }
        .toolbar {
            AttachmentViewerToolbar(viewModel: viewModel)
        }
    }

    private func preview(for attachment: MediaAttachment) -> some View {
        Group {
            if let path = attachment.previewURL, let url = URL(string: path) {
                AsyncImage(url: url, transaction: .init(animation: .easeInOut)) { (phase: AsyncImagePhase) in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .opacity(0.3)
                    default:
                        Color.black
                    }
                }
            }
        }
        .ignoresSafeArea()
        .blur(radius: 16)
    }
}

struct AttachmentViewer_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentViewer(attachments: Array(repeating: MockData.status!.mediaAttachments.first!, count: 4))
    }
}
