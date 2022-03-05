// 
//  YouTrackSubmitButton.swift
//  Codename Shout
//
//  Created by Marquis Kurt on 5/3/22.
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

/// A button used to prompt sending feedback.
///
/// When clicked, the user will be redirected to the YouTrack bug reporter.
struct BetaYouTrackSubmitButton: View {

    enum ButtonPresentationMode {
        case button
        case menuItem
    }

    @Environment(\.openURL) var openURL
    @State var presentationMode: ButtonPresentationMode

    var body: some View {
        Group {
            switch presentationMode {
            case .button:
                button
            case .menuItem:
                button
                    .keyboardShortcut(
                        .init(
                            .init(","),
                            modifiers: [.command, .shift]
                        )
                    )
            }
        }
    }

    private var button: some View {
        Button {
            if let url = URL(string: "https://youtrack.marquiskurt.net/youtrack/newIssue?project=SHU") {
                openURL(url)
            }
        } label: {
            Label("general.feedbackmenu", systemImage: "exclamationmark.bubble")
        }
        .help("help.feedback")
    }
}

struct YouTrackSubmitButton_Previews: PreviewProvider {
    static var previews: some View {
        BetaYouTrackSubmitButton(presentationMode: .button)
    }
}
