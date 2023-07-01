//
//  AuthenticationGateTextField.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/7/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

struct AuthenticationGateTextField: View {
    var focusedDomainEntry: FocusState<Bool>.Binding
    var onTextChange: (String) -> Void
    @State private var domainName = ""

    init(focusedDomainEntry: FocusState<Bool>.Binding,
         onTextChange: @escaping (String) -> Void,
         domainName: String = "") {
        self.focusedDomainEntry = focusedDomainEntry
        self.onTextChange = onTextChange
        self.domainName = domainName
    }

    var body: some View {
        HStack {
            Text("https://")
                .foregroundColor(.secondary)
            TextField("mastodon.example", text: $domainName)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused(focusedDomainEntry)
                .toolbar { keyboardToolbar }
                .onChange(of: domainName) { value in
                    onTextChange(value)
                }
            if !domainName.isEmpty {
                Button {
                    withAnimation {
                        domainName = ""
                    }
                } label: {
                    Label {
                        Text("auth.textfield.clear", bundle: .module)
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .labelStyle(.iconOnly)
                }
                .animation(.easeInOut, value: domainName.isEmpty)
            }

        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.5))
        )
    }

    var keyboardToolbar: some ToolbarContent {
        Group {
            ToolbarItem(id: "auth.spacer", placement: .keyboard) {
                Spacer()
            }
            ToolbarItem(id: "auth.keyboard.done", placement: .keyboard) {
                Button {
                    focusedDomainEntry.wrappedValue.toggle()
                } label: {
                    Text("auth.keyboard.done", bundle: .module)
                }
                .font(.system(.body, design: .rounded))
                .bold()
                .buttonStyle(.borderless)
            }
        }
    }
}

private struct AuthenticationGateTextFieldPreviewer: View {
    @FocusState private var focused: Bool
    @State private var current = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Current text: \(current)")
            AuthenticationGateTextField(focusedDomainEntry: $focused) { value in
                current = value
            }
        }
        .padding()
    }
}

struct AuthenticationGateTextField_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationGateTextFieldPreviewer()
    }
}
