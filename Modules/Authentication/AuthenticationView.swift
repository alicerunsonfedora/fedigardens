//
//  AuthenticationView.swift
//  Gardens
//
//  Created by Marquis Kurt on 9/2/22.
//
//  This file is part of Gardens.
//
//  Gardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Gardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Chica
import Foundation
import SwiftUI

// MARK: - Authentication View

/// A view that displays information prompting the user to authenticate and authorize the app to access Gopherdon.
struct AuthenticationView: View {
    /// Determines whether the device is compact or standard
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The shared Chica authentication object.
    ///
    /// This is used to handle authentication to the Gopherdon server and watch for state changes.
    @ObservedObject private var chicaAuth: Chica.OAuth = .shared

    /// Whether to show the authentication dialog on iOS devices.
    @State private var showAuthDialog: Bool = false

    /// The authentication URL to open in the Safari view controller.
    @State private var authenticationUrl: URL?

    @State private var authenticationDomainName = ""

    // MARK: - Auth View Components

    var body: some View {
        ZStack {
            Group {
                if horizontalSizeClass == .compact {
                    compactModalLayout
                } else {
                    widescreenLayout
                }
            }
            .font(.system(.body, design: .rounded))
        }
        .sheet(isPresented: $showAuthDialog) {
            AuthenticationBrowserWindow(url: $authenticationUrl)
                .edgesIgnoringSafeArea(.all)
                .onChange(of: chicaAuth.authState) { authState in
                    switch authState {
                    case .authenthicated:
                        showAuthDialog = false
                    default:
                        break
                    }
                }
        }
    }

    /// The authentication button.
    private var authForm: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                HStack {
                    Text("https://")
                        .foregroundColor(.secondary)
                    TextField("mastodon.example", text: $authenticationDomainName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.5))
                    )
                Button {
                    Task {
                        await chicaAuth.startOauthFlow(for: authenticationDomainName) { authUrl in
                            authenticationUrl = authUrl
                            showAuthDialog.toggle()
                        }
                    }
                } label: {
                    Text("auth.login.button")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .controlSize(.large)
            HStack {
                Text("auth.footnote")
                    .foregroundColor(.secondary)
                Link(destination: URL(string: "https://joinmastodon.org/servers")!) {
                    Text("auth.footnote.create")
                }
            }
            .font(.footnote)
        }
    }

    // MARK: - Auth View Layouts

    /// The layout used on phones (and macOS, respectively).
    private var compactModalLayout: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 32) {
                welcomeHeader(alignment: .leading)
                Text("auth.startinfo")
                    .font(.title3)
            }
            .padding()
            Spacer()
            authForm
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
    }

    /// The layout to use on iPads.
    private var widescreenLayout: some View {
        HStack(spacing: 8) {
            VStack(alignment: .trailing, spacing: 32) {
                welcomeHeader(alignment: .trailing)
                Text("auth.startinfo")
                    .font(.title3)
            }
            .frame(maxWidth: 450)
            .padding()
            authForm
                .frame(maxWidth: 450)
        }
    }

    // MARK: - Auth View Methods

    /// Returns the welcome header with the specified alignment.
    func welcomeHeader(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
            Image("GardensIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .cornerRadius(16)
            Text("auth.welcome")
                .font(.system(.title2, design: .rounded))
                .bold()
            Text("general.appname")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.accentColor)
        }
    }

    /// Start authenticating the user with Gopherdon.
    public func startAuthentication() {
        Task {
            await chicaAuth.startOauthFlow(for: "mastodon.goucher.edu")
        }
    }
}

// MARK: - Previews

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthenticationView()
                .previewDevice("iPhone 13 Pro")
            AuthenticationView()
                .previewDevice("iPad mini (6th generation)")
                .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
