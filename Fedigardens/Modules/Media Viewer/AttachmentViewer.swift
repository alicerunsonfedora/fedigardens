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

import SwiftUI
import Alice

struct AttachmentViewer: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AttachmentViewerViewModel()
    @GestureState private var scaleEffect = 1.0

    var attachments: [Attachment]

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($scaleEffect) { currentState, gestureState, transaction in
                withAnimation(transaction.animation) {
                    gestureState = currentState
                }
            }
    }

    var body: some View {
        NavigationStack {
            TabView {
                ForEach(attachments, id: \.id) { attachment in
                    AttachmentMedia(attachment: attachment)
                        .aspectRatio(contentMode: viewModel.contentMode)
                        .scaleEffect(scaleEffect)
                        .gesture(zoomGesture)
                        .safeAreaInset(edge: .bottom) {
                            Text(attachment.description ?? "No description provided.")
                                .font(.footnote)
                        }
                        .onAppear {
                            viewModel.currentAttachment = attachment
                        }
                }
                .preferredColorScheme(.dark)
            }
            .tabViewStyle(.page)
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: viewModel.toggleContentMode) {
                        Label("", systemImage: viewModel.systemImageForContentMode())
                    }
                }
                ToolbarItem {
                    Group {
                        if let url = viewModel.currentAttachment?.url {
                            ShareLink(item: url)
                        }
                    }
                }
                ToolbarItem {
                    Button(action: dismiss.callAsFunction) {
                        Text("general.done")
                            .bold()
                    }
                }
            }
        }
        .animation(.spring(), value: viewModel.contentMode)
        .onAppear {
            viewModel.attachments = attachments
        }
    }
}

struct AttachmentViewer_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentViewer(attachments: Array(repeating: MockData.status!.mediaAttachments.first!, count: 4))
    }
}
