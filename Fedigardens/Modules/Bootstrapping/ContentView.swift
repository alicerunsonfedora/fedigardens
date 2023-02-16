//
//  ContentView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 25/1/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import SwiftUI

// MARK: - Content View

/// The primary content view of the app.
struct ContentView: View {
    @Environment(\.deviceModel) private var deviceModel
    @State private var showAuthSheet: Bool = false
    @ObservedObject private var authModule = AuthenticationModule.shared

    var body: some View {
        VStack {
            Group {
                switch authModule.authenticationState {
                case .authenticated:
                    if deviceModel.starts(with: "iPad") {
                        GardensAppWideLayout()
                    } else {
                        GardensAppCompactLayout()
                    }
                default:
                    authDialog
                }
            }
        }
        .animation(.spring(), value: authModule.authenticationState)
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
