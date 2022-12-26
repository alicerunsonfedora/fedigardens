//
//  AuthorView.swift
//  Gardens
//
//  Created by Marquis Kurt on 15/2/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import enum Chica.Visibility
import Foundation
import SwiftUI
import UIKit

// MARK: - Author View

/// A view that displays a text editor used to make posts on Gopherdon.
struct AuthorView: View {
    /// An environment variable used to dismiss the view if this were displayed as a sheet.
    @Environment(\.dismiss) var dismiss

    /// The ID of the status that the current status will respond to, if the user is replying.
    ///
    /// Typically, this is used on macOS variants where a deep link is used to display the window.
    @State var authoringContext: AuthoringContext?

    @StateObject private var viewModel = AuthorViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Section {
                    visibilityPicker
                    Toggle("status.marksensitive", isOn: $viewModel.sensitive)
                    replySection
                }

                if let context = authoringContext, !context.forwardingURI.isEmpty {
                    Section {
                        VStack(alignment: .leading) {
                            Label("status.quoted.title", systemImage: "quote.bubble")
                                .font(.headline)
                            Text("status.quoted.detail")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    statusText
                        .frame(minHeight: 250)
                    HStack {
                        Spacer()
                        charsRemainText
                    }
                    .listRowSeparator(.hidden)
                }

                if viewModel.sensitive {
                    Section {
                        TextField("status.spoilerplaceholder", text: $viewModel.sensitiveText)
                    } footer: {
                        Label {
                            VStack(alignment: .leading) {
                                Text("status.spoilerprompt")
                                    .bold()
                                    .foregroundColor(.indigo)
                                Text("status.spoilerdetail")
                            }
                        } icon: {
                            Image(systemName: "eye.trianglebadge.exclamationmark")
                                .foregroundColor(.indigo)
                        }
                    }
                    .animation(.spring(), value: viewModel.sensitive)
                    .tint(.indigo)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(
            viewModel.prompt == nil ? "status.new" : "status.newreply"
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("actions.cancel", systemImage: "xmark")
                }
                .keyboardShortcut(.cancelAction)
                .tint(.gray)
            }
            ToolbarItem {
                Button {
                    Task {
                        await viewModel.submitStatus {
                            dismiss()
                        }
                    }
                } label: {
                    Label("status.postaction", systemImage: "paperplane")
                }
                .keyboardShortcut(.init(.return, modifiers: [.command]))
                .tint(.accentColor)
                .disabled(viewModel.charactersRemaining < 0)
            }
        }
        .onAppear {
            Task {
                if let context = authoringContext {
                    await viewModel.setupTextContents(with: context)
                }
            }
        }
    }

    // MARK: - Author View Computed Subviews

    private var replyBanner: some View {
        HStack {
            replySection
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.accentColor.opacity(0.1))
        .tint(.accentColor)
    }

    var replySection: some View {
        Group {
            if let reply = viewModel.prompt {
                AuthorReplySegment(reply: reply)
            }
        }
    }

    private var charsRemainText: some View {
        Text("\(viewModel.charactersRemaining)")
            .font(.system(.body, design: .monospaced))
            .foregroundColor(getColorForChars())
    }

    private var statusText: some View {
        TextEditor(text: $viewModel.text)
            .font(.system(.title3, design: .serif))
            .lineSpacing(1.2)
            .onChange(of: viewModel.text) { newText in
                viewModel.reformatText(with: newText)
            }
    }

    private var sensitivePrompt: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .foregroundColor(.indigo)
            VStack(alignment: .leading, spacing: 4) {
                Text("status.spoilerprompt")
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.indigo)
                    .bold()
                Text("status.spoilerdetail")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.indigo)
                TextField("status.spoilerplaceholder", text: $viewModel.sensitiveText)
                    .textFieldStyle(.roundedBorder)
            }
            .foregroundColor(.secondary)
        }
        .padding()
    }

    private var sensitiveBanner: some View {
        HStack {
            sensitivePrompt
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.indigo.opacity(0.1))
        .tint(.yellow)
    }

    private var visibilityPicker: some View {
        Picker("status.visibility", selection: $viewModel.visibility) {
            Text("status.visibility.public").tag(Visibility.public)
            Text("status.visibility.unlisted").tag(Visibility.unlisted)
            Text("status.visibility.private").tag(Visibility.private)
            Text("status.visibility.direct").tag(Visibility.direct)
        }
        .font(.system(.body, design: .rounded))
    }

    // MARK: - Author View Methods

    /// Returns the foreground color used to color the characters remaining text, to subtly warn the user if they are
    /// about to go over the limit.
    private func getColorForChars() -> Color {
        switch viewModel.charactersRemaining {
        case let chars where chars < 0:
            return Color.red
        case let chars where chars > 0 && chars <= 25:
            return Color.yellow
        default:
            return Color.secondary
        }
    }

    /// Submits the status to Gopherdon as a POST request, then attempts to close the window.
    
}

// MARK: - Previews

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthorView()
        }
    }
}
