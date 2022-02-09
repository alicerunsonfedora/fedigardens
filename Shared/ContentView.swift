//
//  ContentView.swift
//  Shared
//
//  Created by Marquis Kurt on 25/1/22.
//  This file is part of Codename Shout.
//
//  Codename Shout is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Codename Shout comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Chica

struct ContentView: View {

    /// The shared Chica authentication object.
    ///
    /// This is used to handle authentication to the Gopherdon server and watch for state changes.
    @ObservedObject private var chicaAuth: Chica.OAuth = Chica.OAuth.shared

    var body: some View {
        VStack {
            authStateTest
        }
    }

    private var authStateTest: some View {
        Group {
            if chicaAuth.authState == .signedOut {
                AuthenticationView()
            } else {
                VStack {
                    Label {
                        Text("Authenticated")
                            .bold()
                    } icon: {
                        Image(systemName: "person.crop.circle.fill.badge.checkmark")
                            .foregroundColor(.green)
                    }
                    .font(.system(.largeTitle, design: .rounded))

                    Button {
                        Task {
                            if let test: Account? = try! await Chica.shared.request(.get, for: .verifyAccountCredentials) {
                                print(test?.username ?? "unknown username")
                            }
                        }
                    } label: {
                        Text("Fetch Test Data")
                    }
                }
                .padding()

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
