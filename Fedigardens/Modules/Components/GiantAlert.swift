//
//  GiantAlert.swift
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

struct GiantAlert<Icon: View, Actions: View, Message: View>: View {
    @Environment(\.dismiss) var dismissAction
    var title: LocalizedStringKey
    var icon: () -> Icon?
    var actions: () -> Actions
    var message: () -> Message?

    init(
        title: LocalizedStringKey,
        @ViewBuilder icon: @escaping () -> Icon? = { nil },
        @ViewBuilder actions: @escaping () -> Actions,
        @ViewBuilder message: @escaping () -> Message? = { nil }
    ) {
        self.title = title
        self.actions = actions
        self.message = message
        self.icon = icon
    }

    var body: some View {
        VStack(spacing: 8) {
            if let icon {
                icon()
                    .font(.largeTitle)
                    .imageScale(.large)
                    .padding(.top)
            }
            Text(title)
                .font(.largeTitle)
                .bold()
            ScrollView(.vertical) {
                if let message {
                    message()
                } else {
                    defaultMessage
                }
            }
            Spacer()
            Group {
                actions()
            }
            .controlSize(.large)
        }
        .padding()
    }

    private var defaultMessage: some View {
        EmptyView()
    }
}

struct GiantAlertModifier<Icon: View, Actions: View, Message: View>: ViewModifier {
    var isPresented: Binding<Bool>
    var title: LocalizedStringKey
    var icon: (() -> Icon)?
    var actions: () -> Actions
    var message: (() -> Message)?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isPresented) {
                GiantAlert(
                    title: title,
                    icon: icon ?? { nil },
                    actions: actions,
                    message: message ?? { nil }
                )
            }
    }
}

extension View {
    func giantAlert<I: View, A: View, M: View>(
        isPresented: Binding<Bool>,
        title: LocalizedStringKey,
        @ViewBuilder icon: @escaping () -> I? = { nil },
        @ViewBuilder actions: @escaping () -> A,
        @ViewBuilder message: @escaping () -> M? = { nil }
    ) -> some View {
        self.modifier(
            GiantAlertModifier(
                isPresented: isPresented,
                title: title,
                icon: icon,
                actions: actions,
                message: message
            )
        )
    }
}

struct GiantAlertTestView: View {
    @State private var pressed = false

    var body: some View {
        VStack {
            Button {
                pressed.toggle()
            } label: {
                Text("Press Me")
            }
        }
        .giantAlert(isPresented: $pressed, title: "attachments.share.title") {
            Image(systemName: "square.and.arrow.up")
        } actions: {
            Button {
                pressed = false
            } label: {
                Text("attachments.share.acknowledge")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Button(role: .cancel) {
                pressed = false
            } label: {
                Text("general.cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        } message: {
            Text("attachments.share.detail")
        }
    }
}

struct GiantAlert_Previews: PreviewProvider {
    static var previews: some View {
        GiantAlertTestView()
    }
}
