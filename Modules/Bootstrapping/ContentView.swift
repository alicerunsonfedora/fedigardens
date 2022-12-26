//
//  ContentView.swift
//  Gardens
//
//  Created by Marquis Kurt on 25/1/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import SwiftUI

// MARK: - Content View

/// The primary content view of the app.
struct ContentView: View {
    /// Determines whether the device is compact or standard
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The shared Chica authentication object.
    ///
    /// This is used to handle authentication to the Gopherdon server and watch for state changes.
    @ObservedObject private var chicaAuth: Chica.OAuth = .shared

    @State private var showAuthSheet: Bool = false

    var body: some View {
        VStack {
            Group {
                switch chicaAuth.authState {
                case .authenthicated:
                    GardensAppLayout()
                default:
                    authDialog
                }
            }
        }
        .animation(.spring(), value: chicaAuth.authState)
    }

    var authDialog: AuthenticationView {
        AuthenticationView()
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
