//
//  InterventionMissingAlert.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 26/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI

public extension View {
    /// Presents an alert to the user that one sec could not be found, preventing an intervention from being requested.
    /// 
    /// - Parameter isPresented: Whether the alert is being presented.
    /// - Parameter opener: The action that will open the URL to one sec's App Store page.
    /// - Parameter disableAction: A closure that executes when the user presses the action to disable interventions.
    func interventionsAlert(isPresented: Binding<Bool>,
                            opener: OpenURLAction,
                            disableAction: @escaping () -> Void) -> some View {
        self.alert(
            NSLocalizedString("interventions.missing.title", bundle: .module, comment: ""),
            isPresented: isPresented) {
            Button {
                if let url = URL(
                    string: "https://apps.apple.com/app/apple-store/id1532875441?pt=120233067&ct=fedigardens") {
                    opener(url)
                }
            } label: {
                Text("interventions.cta.install", bundle: .module)
            }
            Button {
                disableAction()
            } label: {
                Text("interventions.cta.disable", bundle: .module)
            }
            Button {} label: {
                Text("interventions.cta.dismiss", bundle: .module)
            }.keyboardShortcut(.defaultAction)
        } message: {
            Text("interventions.missing.detail", bundle: .module)
        }
    }
}

struct DummyInterventionView: View {
    @Environment(\.openURL) var openURL: OpenURLAction

    @State private var toggleAlert = false
    var body: some View {
        VStack {
            Button {
                toggleAlert.toggle()
            } label: {
                Text("Click me!")
            }
        }
        .interventionsAlert(isPresented: $toggleAlert, opener: openURL) {
            print("I was pressed!")
        }

    }
}

struct InterventionAlertPreview_Previews: PreviewProvider {
    static var previews: some View {
        DummyInterventionView()
    }
}
