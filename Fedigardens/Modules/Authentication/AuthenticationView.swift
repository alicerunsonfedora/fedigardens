//
//  AuthenticationView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 9/2/22.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Alice
import Foundation
import SwiftUI

// MARK: - Authentication View

/// A view that displays information prompting the user to authenticate and authorize the app to access Gopherdon.
struct AuthenticationView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) var openURL: OpenURLAction

    @StateObject private var viewModel = AuthenticationViewModel()

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
        .alert(viewModel.authenticationRejectionTitle, isPresented: $viewModel.authenticationDomainRejected) {
            Button {
                if let url = URL(string: "https://fedigardens.app/support") {
                    openURL(url)
                }
            } label: {
                Text("general.learnmore")
            }
            Button {

            } label: {
                Text("OK")
            }.keyboardShortcut(.defaultAction)
        } message: {
            Text("auth.disallowed.message")
        }
    }

    /// The authentication button.
    private var authForm: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                HStack {
                    Text("https://")
                        .foregroundColor(.secondary)
                    TextField("mastodon.example", text: $viewModel.authenticationDomainName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.5))
                    )
                Button {
                    Task { await viewModel.startAuthenticationWorkflow() }
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
