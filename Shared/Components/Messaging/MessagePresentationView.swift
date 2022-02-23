// 
//  MessagePresentationView.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 23/2/22.
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

struct MessagePresentationView: View {
    var body: some View {
        VStack {
            HStack {
                MessagePresentationBubble(message: MockData.status!)
                    .presentationStyle(.recipient)
                Spacer()
            }
            HStack {
                Spacer()
                MessagePresentationBubble(message: MockData.status!)
                    .presentationStyle(.sender)
            }
            HStack {
                MessagePresentationBubble(message: MockData.status!)
                    .presentationStyle(.recipient)
                Spacer()
            }
            HStack {
                MessagePresentationBubble(message: MockData.status!)
                    .presentationStyle(.recipient)
                Spacer()
            }
            HStack {
                Spacer()
                MessagePresentationBubble(message: MockData.status!)
                    .presentationStyle(.sender)
            }
        }
        .padding()

    }
}

fileprivate struct MessagePresentationBubble: View {

    enum PresentationStyle {
        case sender
        case recipient
    }

    @State var message: Status
    @State fileprivate var presentationStyle: PresentationStyle
    @State private var content = "Hello, world!"

    init(message: Status) {
        self.init(message: message, presentationStyle: .recipient)
    }

    fileprivate init(message: Status, presentationStyle: PresentationStyle) {
        self.message = message
        self.presentationStyle = presentationStyle
    }

    var body: some View {
        HStack(alignment: .bottom) {
            if presentationStyle == .recipient {
                AsyncImage(url: URL(string: message.account.avatarStatic)!) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
                .frame(width: 32, height: 32)
            }
            Group {
                switch presentationStyle {
                case .sender:
                    baseTextView
                        .background(Color.indigo)
                        .foregroundColor(.white)

                case .recipient:
                    baseTextView
                        .background(Color.secondary.opacity(0.5))
                }
            }
            .clipShape(Capsule())
        }
    }

    private var baseTextView: some View {
        Text(content)
            .padding()
            .onAppear {
                Task {
                    content = await message.content.toPlainText()
                }
            }
    }
}

fileprivate extension MessagePresentationBubble {
    func presentationStyle(_ presentation: PresentationStyle) -> some View {
        MessagePresentationBubble(message: self.message, presentationStyle: presentation)
    }
}

struct MessagePresentationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagePresentationView()
            MessagePresentationView()
                .preferredColorScheme(.dark)
        }

    }
}
