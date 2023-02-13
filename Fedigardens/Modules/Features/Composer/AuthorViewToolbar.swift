//
//  AuthorViewToolbar.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/4/23.
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

struct AuthorViewToolbar: ToolbarContent {
    @Environment(\.locale) var locale
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AuthorViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Label("general.cancel", systemImage: "xmark")
            }
            .keyboardShortcut(.escape, modifiers: .command)
            .labelStyle(.titleOnly)
        }

        ToolbarItem(placement: .primaryAction) {
            EditButton()
                .disabled(!viewModel.includesPoll)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button(action: startSubmission) {
                ZStack {
                    // NOTE: This text exists so that the option shows in the keyboard shortcuts menu.
                    Text("status.postaction")
                        .frame(width: 0, height: 0)
                        .opacity(0)
                    Label("status.postaction", systemImage: "arrow.up.circle.fill")
                        .font(.title)
                        .tint(.accentColor)
                }
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(viewModel.shouldDisableSubmission)
        }

        ToolbarItem(placement: .bottomBar) {
            Toggle(isOn: $viewModel.sensitive) {
                ZStack {
                    Text("status.marksensitive")
                        .frame(width: 0, height: 0)
                        .opacity(0)
                    Label("status.marksensitive", systemImage: "eye.trianglebadge.exclamationmark")
                }
            }
            .keyboardShortcut("w", modifiers: [.command, .control])
        }

        ToolbarItem(placement: .bottomBar) {
            Toggle(isOn: $viewModel.includesPoll) {
                Label("status.poll.create", systemImage: "checklist")
            }
            .keyboardShortcut("p", modifiers: [.command, .control])
            .onChange(of: viewModel.includesPoll) { updated in
                if updated {
                    viewModel.pollExpirationDate = .now.advanced(by: 300)
                }
            }
        }

        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.pollOptions.append("")
            } label: {
                Label("status.poll.addoption", systemImage: "plus.circle")
            }
            .disabled(!viewModel.includesPoll || viewModel.pollOptions.count >= 4)
            .keyboardShortcut("+", modifiers: [.option, .shift])
            .tint(.accentColor)
        }

        ToolbarItem(placement: .bottomBar) {
            Picker(selection: $viewModel.selectedLanguage) {
                ForEach(viewModel.availableLanguageCodes, id: \.hashValue) { code in
                    Text(locale.localizedString(forLanguageCode: code) ?? code)
                        .tag(code)
                }
            } label: {
                Label("status.languagecode", systemImage: "globe")
            }
            .keyboardShortcut("l", modifiers: [.command, .control])
        }
    }

    private func startSubmission() {
        Task {
            await viewModel.submitStatus {
                dismiss()
            }
        }
    }
}

struct AuthorViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthorView(authoringContext: .init(participants: "@test@mastodon.example"))
        }
    }
}
