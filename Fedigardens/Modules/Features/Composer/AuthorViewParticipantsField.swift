//
//  AuthorViewParticipantsField.swift
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

import Alice
import Bunker
import SwiftUI

struct AuthorViewParticipantsField: View {
    @StateObject var viewModel: AuthorViewModel

    var body: some View {
        HStack {
            Text(viewModel.visibility == .direct ? "To: " : "Cc: ")
            TextField("status.participants.empty", text: $viewModel.mentionString, axis: .vertical)
                .lineLimit(1 ... 3)
                .textInputAutocapitalization(.none)
                .multilineTextAlignment(.trailing)
                .autocorrectionDisabled()
                .foregroundColor(.accentColor)
                .keyboardType(.emailAddress)
            if viewModel.mentionString.isNotEmpty {
                Button {
                    viewModel.mentionString = ""
                } label: {
                    Label("Clear", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
