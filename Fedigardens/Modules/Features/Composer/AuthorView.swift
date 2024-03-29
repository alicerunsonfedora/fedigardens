//
//  AuthorView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 15/2/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import GardenComposer
import SwiftUI
import UIKit

// MARK: - Author View

/// A view that displays a text editor used to make posts on Gopherdon.
struct AuthorView: View {
    /// An environment variable used to dismiss the view if this were displayed as a sheet.
    @Environment(\.dismiss) var dismiss

    @Environment(\.userProfile) var userProfile

    /// The ID of the status that the current status will respond to, if the user is replying.
    ///
    /// Typically, this is used on macOS variants where a deep link is used to display the window.
    @State var authoringContext: AuthoringContext?

    @StateObject private var viewModel = AuthorViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Section {
                    editingNotice
                    visibilityPicker
                    if !viewModel.editMode {
                        AuthorViewParticipantsField(viewModel: viewModel)
                    }
                    if viewModel.sensitive {
                        HStack {
                            Image(systemName: "eye.trianglebadge.exclamationmark")
                                .foregroundColor(.indigo)
                            TextField("status.spoilerplaceholder", text: $viewModel.sensitiveText)
                        }
                    }
                } footer: {
                    if viewModel.sensitive {
                        Text("status.spoilerdetail")
                            .font(.footnote)
                    }
                }
                Section {
                    statusText
                    charsRemainText
                        .listRowSeparator(.hidden)
                    quoteSection
                    replyAndTagSection
                }

                if viewModel.includesPoll {
                    Section {
                        ForEach(0 ..< viewModel.pollOptions.count, id: \.self) { index in
                            TextField("status.poll.optionplaceholder", text: $viewModel.pollOptions[index])
                        }
                        .onDelete { indexSet in
                            guard viewModel.pollOptions.count >= 2 else { return }
                            viewModel.pollOptions.remove(atOffsets: indexSet)
                        }
                    } header: {
                        Text("status.poll.optionssection")
                    }
                    DatePicker("status.poll.authorexpiry", selection: $viewModel.pollExpirationDate)
                }
                replySection
            }
            .listStyle(.inset)
        }
        .navigationTitle(viewModel.proposedNavigationTitle)
        .animation(.spring(), value: viewModel.textContainsHashtagInReply)
        .animation(.spring(), value: viewModel.prompt)
        .animation(.spring(), value: viewModel.sensitive)
        .animation(.spring(), value: viewModel.charactersRemaining)
        .animation(.spring(), value: viewModel.includesPoll)
        .toolbarBackground(.visible, for: .bottomBar)
        .toolbar {
            AuthorViewToolbar(viewModel: viewModel)
        }
        .onContinueUserActivity("app.fedigardens.mail.authorscene", perform: continueActivity)
        .onAppear {
            Task {
                if let context = authoringContext {
                    viewModel.setAuthor(to: userProfile)
                    await viewModel.setupTextContents(with: context)
                }
            }
        }
        .onChange(of: authoringContext) { newValue in
            Task {
                if let context = newValue {
                    viewModel.setAuthor(to: userProfile)
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

    var replyAndTagSection: some View {
        Group {
            if viewModel.textContainsHashtagInReply {
                VStack(alignment: .leading) {
                    Label("status.tagandreply.title", systemImage: "tag")
                        .font(.headline)
                    Text("status.tagandreply.detail")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    var editingNotice: some View {
        Group {
            if viewModel.editMode {
                VStack(alignment: .leading) {
                    Label("status.editmode.title", systemImage: "pencil")
                        .font(.headline)
                    Text("status.editmode.detail")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    var quoteSection: some View {
        Group {
            if let context = authoringContext, !context.forwardingURI.isEmpty {
                VStack(alignment: .leading) {
                    Label("status.quoted.title", systemImage: "quote.bubble")
                        .font(.headline)
                    Text("status.quoted.detail")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var charsRemainText: some View {
        Text(
            String(
                format: "status.charsremain".localized(comment: "Characters remaining"),
                viewModel.charactersRemaining
            )
        )
        .font(.system(.footnote, design: .rounded))
        .monospacedDigit()
        .foregroundColor(getColorForChars())
    }

    private var statusText: some View {
        TextEditor(text: $viewModel.text)
            .font(.system(.body, design: .rounded))
            .lineLimit(5, reservesSpace: true)
            .lineSpacing(1.1)
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

    private var visibilityPicker: some View {
        Picker("status.visibility", selection: $viewModel.visibility) {
            ForEach(PostVisibility.allCases, id: \.hashValue) { visibilityCase in
                Text(visibilityCase.localizedDescription).tag(visibilityCase)
            }
        }
        .font(.system(.body, design: .rounded))
        .disabled(viewModel.editMode)
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

    private func continueActivity(_ activity: NSUserActivity) {
        if let data = activity.userInfo?["AuthoringContextDetails"] as? String, let url = URL(string: data) {
            authoringContext = AuthoringContext(from: url)
        }
    }
}

// MARK: - Previews

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthorView(authoringContext: .init(participants: "@test@mastodon.example"))
        }
    }
}
