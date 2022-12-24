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

    /// The status that the current status will respond to, if the user is replying.
    @State var prompt: Status?

    /// The ID of the status that the current status will respond to, if the user is replying.
    ///
    /// Typically, this is used on macOS variants where a deep link is used to display the window.
    @State var promptId: Binding<String>?

    /// The body of the status that's being authored.
    @State var text: String = ""

    /// The visibility of the status. Defaults to public.
    @State var visibility: Visibility = .public

    /// Whether the post should be marked as sensitive. Defaults to false.
    @State private var sensitive: Bool = false

    /// A prompt content variable used to render the status's text asynchronously.
    @State private var promptContent = "Content goes here."

    /// Associated warning text with a sensitive status context.
    @State private var sensitiveText = ""

    /// The number of characters remaining that the user can utilize.
    private var charactersRemaining: Int { 500 - text.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Section {
                    visibilityPicker
                    Toggle("status.marksensitive", isOn: $sensitive)
                    replySection
                    statusText
                        .frame(minHeight: 250)
                    HStack {
                        Spacer()
                        charsRemainText
                    }
                    .listRowSeparator(.hidden)
                }
                if sensitive {
                    Section {
                        TextField("status.spoilerplaceholder", text: $sensitiveText)
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
                    .animation(.spring(), value: sensitive)
                    .tint(.indigo)
                }
            }
            .listStyle(.grouped)
        }
        .navigationTitle(
            prompt == nil ? "status.new" : "status.newreply"
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
                        await submit()
                    }
                } label: {
                    Label("status.postaction", systemImage: "paperplane")
                }
                .keyboardShortcut(.init(.return, modifiers: [.command]))
                .tint(.accentColor)
                .disabled(charactersRemaining < 0)
            }
        }
        .onAppear {
            Task {
                if let unwrappedPrompt = promptId {
                    let trueId = unwrappedPrompt.wrappedValue
                    if !trueId.isEmpty, prompt == nil {
                        prompt = try! await Chica.shared.request(.get, for: .statuses(id: trueId))
                    }
                }
                await constructReplyText()
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
            if let reply = prompt {
                AuthorReplySegment(reply: reply)
            }
        }
    }

    private var charsRemainText: some View {
        Text("\(charactersRemaining)")
            .font(.system(.body, design: .monospaced))
            .foregroundColor(getColorForChars())
    }

    private var statusText: some View {
        TextEditor(text: $text)
            .font(.system(.title3, design: .serif))
            .lineSpacing(1.2)
            .onChange(of: text) { newText in
                text = newText.count < 600
                    ? newText
                    : String(newText[...newText.index(newText.startIndex, offsetBy: 600)])
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
                TextField("status.spoilerplaceholder", text: $sensitiveText)
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
        Picker("status.visibility", selection: $visibility) {
            Text("status.visibility.public").tag(Visibility.public)
            Text("status.visibility.unlisted").tag(Visibility.unlisted)
            Text("status.visibility.private").tag(Visibility.private)
            Text("status.visibility.direct").tag(Visibility.direct)
        }
        .font(.system(.body, design: .rounded))
    }

    // MARK: - Author View Methods

    /// Initialized the reply text if there is a prompted status to reply to.
    ///
    /// This will attempt to load in the usernames of the mentioned people in the thread, like most Mastodon clients
    /// do, to maintain consistency and clarity in the conversation thread.
    private func constructReplyText() async {
        guard let reply = prompt else { return }
        let respondent = "@\(reply.account.acct)"
        let otherMembers = reply.mentions
            .map { mention in "@\(mention.acct)" }
            .filter { name in name != respondent }
            .joined(separator: " ")
        text = "\(respondent) \(otherMembers) "
    }

    /// Returns the foreground color used to color the characters remaining text, to subtly warn the user if they are
    /// about to go over the limit.
    private func getColorForChars() -> Color {
        switch charactersRemaining {
        case let chars where chars < 0:
            return Color.red
        case let chars where chars > 0 && chars <= 25:
            return Color.yellow
        default:
            return Color.secondary
        }
    }

    /// Returns a localized version of the navigation subtitle on macOS, which displays the number of characters
    /// remaining.
    private func makeSubtitle() -> String {
        guard let reply = prompt else {
            return ""
        }
        return String(
            format: NSLocalizedString("status.replysubtitle", comment: "reply"),
            reply.account.getAccountName()
        )
    }

    /// Submits the status to Gopherdon as a POST request, then attempts to close the window.
    private func submit() async {
        if charactersRemaining < 0 {
            return
        }

        var params = [
            "status": text,
            "visibility": visibility.rawValue,
            "poll": "null"
        ]

        if let reply = prompt {
            params["in_reply_to_id"] = reply.id
        }

        if sensitive {
            params["sensitive"] = "true"
            params["spoiler_text"] = sensitiveText
        }

        do {
            let _: Status? = try await Chica.shared
                .request(.post, for: .statuses(id: nil), params: params)
            dismiss()
        } catch {
            print("Some other error occurred here.")
            print(error.localizedDescription)
        }
    }
}

// MARK: - Previews

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthorView(text: "Enter your status here...")
//            NavigationView {
            AuthorView(prompt: MockData.status, text: "Enter your reply here...")
//            }
        }
    }
}
