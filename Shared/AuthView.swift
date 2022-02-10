// 
//  AuthView.swift
//  Capstone
//
//  Created by Marquis Kurt on 9/2/22.
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

struct AuthenticationView: View {

#if os(iOS)
    /// Determines whether the device is compact or standard
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

    /// The shared Chica authentication object.
    ///
    /// This is used to handle authentication to the Gopherdon server and watch for state changes.
    @ObservedObject private var chicaAuth: Chica.OAuth = Chica.OAuth.shared

    /// Whether to show the authentication dialog on iOS devices.
    @State private var showAuthDialog: Bool = false

    // MARK: - Auth View Components

    var body: some View {
        ZStack {
            pinstripes
                .edgesIgnoringSafeArea(.all)
            Group {
#if os(iOS)
                if horizontalSizeClass == .compact {
                    compactModalLayout
                } else {
                    widescreenLayout
                }
#else
                compactModalLayout
#endif
            }
            .font(.system(.body, design: .rounded))
        }
        .sheet(isPresented: $showAuthDialog) {
            NavigationView {
                authSheet
            }
            .onAppear {
                Task {
                    await chicaAuth.startOauthFlow(for: "mastodon.goucher.edu")
                }
            }
            .onChange(of: chicaAuth.authState) { authState in
                switch authState {
                case .authenthicated(_):
                    showAuthDialog = false
                default:
                    break
                }
            }
        }
    }

    /// The view displayed in the authentication sheet.
    var authSheet: some View {
        VStack(spacing: 8) {
            Text("🎸")
                .font(.system(size: 76))
            Text("auth.progress")
                .textCase(.uppercase)
                .foregroundColor(.secondary)
            ProgressView()
        }
        .toolbar {
            ToolbarItem {
                Button {

                } label: {
                    Label("general.feedback", systemImage: "exclamationmark.bubble")
                }
            }
        }
    }

    /// The background view used to render the pinstripes in the corner of the window.
    private var pinstripes: some View {
        GeometryReader { g in
            let halfWidth = g.size.width / 2
            let halfHeight = g.size.height / 2

#if os(iOS)
            let frameWidth = horizontalSizeClass == .compact ? halfWidth * 1.5 : halfWidth
            let frameHeight = horizontalSizeClass == .compact ? halfWidth * 1.5 : halfWidth
            let xOffset = horizontalSizeClass == .compact ? halfWidth / 2 : halfWidth
            let yOffset = horizontalSizeClass == .compact ? 0 : -halfHeight / 2
#else
            let frameWidth = halfWidth
            let frameHeight = halfWidth
            let xOffset = halfWidth
            let yOffset = -halfHeight / 2
#endif

            Image("Pinstripes")
                .resizable()
                .frame(width: frameWidth, height: frameHeight)
                .offset(x: xOffset, y: yOffset)
        }
    }

    /// The authentication button.
    private var authButton: some View {
        VStack(spacing: 8) {
            Button {
                showAuthDialog.toggle()
            } label: {
                Text("auth.login.button")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            HStack {
                Text("auth.footnote")
                    .foregroundColor(.secondary)
                Link(destination: URL(string: "https://mastodon.goucher.edu/auth/sign_up")!) {
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
#if os(iOS)
            authButton
#endif
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
            authButton
                .frame(maxWidth: 450)
        }
    }

    // MARK: - Auth View Methods

    /// Returns the welcome header with the specified alignment.
    func welcomeHeader(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment) {
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
#if os(macOS)
        Task {
            await chicaAuth.startOauthFlow(for: "mastodon.goucher.edu")
        }
#else
        showAuthDialog.toggle()
#endif
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
            NavigationView {
                AuthenticationView().authSheet
            }
        }
    }
}
