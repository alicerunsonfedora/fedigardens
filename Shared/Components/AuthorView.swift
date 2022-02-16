// 
//  AuthorView.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 15/2/22.
//
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import SwiftUI
import Chica
import enum Chica.Visibility

#if os(iOS)
import UIKit
#endif

struct AuthorView: View {

    #if os(iOS)
    @Environment(\.dismiss) var dismiss
    #endif

    @State var prompt: Status?
    @State var promptId: Binding<String>?
    @State var text: String = ""
    @State var visibility: Visibility = .public

    @State private var promptContent = "Content goes here."

    private var charactersRemaining: Int { 500 - text.count }

    var body: some View {
        VStack(alignment: .leading) {
            #if os(iOS)
            List {
                Section {
                    visibilityPicker
                    statusText
                        .frame(minHeight: 250)
                    HStack {
                        Spacer()
                        charsRemainText
                    }
                }

                if let reply = prompt {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                String(
                                    format: NSLocalizedString("status.replytext", comment: "reply"),
                                    reply.account.username
                                )
                            )
                                .font(.system(.callout, design: .rounded))
                                .bold()
                            Text(promptContent)
                        }
                        .foregroundColor(.secondary)
                        .onAppear {
                            Task {
                                promptContent = await reply.content.toPlainText()
                            }
                        }
                    }
                }
            }
            .listStyle(.grouped)
            #else
            statusText
            if let reply = prompt {
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        String(
                            format: NSLocalizedString("status.replytext", comment: "reply"),
                            reply.account.username
                        )
                    )
                        .font(.system(.callout, design: .rounded))
                        .bold()
                    Text(promptContent)
                }
                .padding()
                .foregroundColor(.secondary)
                .onAppear {
                    Task {
                        promptContent = await reply.content.toPlainText()
                    }
                }
            }
            #endif
        }
        .navigationTitle("status.new")
#if os(macOS)
        .navigationSubtitle(makeSubtitle())
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("actions.cancel", systemImage: "xmark")
                }
                .keyboardShortcut(.cancelAction)
                .tint(.gray)
            }
#endif

#if os(macOS)
            ToolbarItem {
                visibilityPicker
            }
#endif
            ToolbarItem {
                Button {
                    Task {
                        await submit()
                    }
                } label: {
                    Label("status.postaction", systemImage: "paperplane")
                }
                .keyboardShortcut(.defaultAction)
                .tint(.accentColor)
            }

        }
        .onAppear {
            Task {
                if let unwrappedPrompt = promptId {
                    let trueId = unwrappedPrompt.wrappedValue
                    if !trueId.isEmpty && prompt == nil {
                        prompt = try! await Chica.shared.request(.get, for: .statuses(id: trueId))
                    }
                }
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
            .font(.system(.body, design: .serif))
            .lineSpacing(1.2)
    }

    private var visibilityPicker: some View {
        Picker("status.visibility", selection: $visibility) {
            Text("status.visibility.public").tag(Visibility.public)
            Text("status.visibility.unlisted").tag(Visibility.unlisted)
            Text("status.visibility.private").tag(Visibility.private)
        }
        .font(.system(.body, design: .rounded))
    }

    private func getColorForChars() -> Color {
        switch charactersRemaining {
        case let chars where chars < 0:
            return Color.red
        case let chars where chars > 0 && chars <= 25:
            return Color.yellow
        default:
            return Color.primary
        }
    }

    private func makeSubtitle() -> String {
        String(
            format: NSLocalizedString("status.charsremain", comment: ""),
            charactersRemaining
        )
    }

    private func submit() async {
        var params = [
            "status" : text,
            "visibility": visibility.rawValue,
            "poll": "null"
        ]

        if let reply = prompt {
            params["in_reply_to_id"] = reply.id
        }

        do {
            let _: Status? = try await Chica.shared
                .request(.post, for: .statuses(id: nil), params: params)
#if os(macOS)
            await NSApplication.shared.keyWindow?.close()
#else
            dismiss()
#endif
        } catch {
            print("Some other error occurred here.")
            print(error.localizedDescription)
        }
    }
}

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthorView()
            NavigationView {
                AuthorView(prompt: MockData.status)
            }

        }

    }
}
