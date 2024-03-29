//
//  AuthenticationGateView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 24/6/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import FlowKit
import SwiftUI

public struct AuthenticationGateView: StatefulView {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) var openURL: OpenURLAction

    @State private var callbackUrl: URL?
    @State private var displayAuthenticationDialog = false
    @State private var displayDomainValidationError = false
    @State private var domainValidationErrorTitle = ""
    @FocusState private var focusedDomainEntry: Bool

    public var flow = AuthenticationGate(auth: .shared, network: .shared)

    public init() {}

    public var statefulBody: some View {
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
        .sheet(isPresented: $displayAuthenticationDialog) {
            AuthenticationGateBrowser(url: $callbackUrl)
                .edgesIgnoringSafeArea(.all)
        }
        .alert(
            NSLocalizedString("auth.failure.title", bundle: .module, comment: "Could not sign in"),
            isPresented: $displayDomainValidationError) {
                Link(destination: URL(string: "https://fedigardens.app/support")!) {
                    Text("auth.learnmore", bundle: .module)
                }
                Link(destination: URL(string: "https://feedback.marquiskurt.net/t/fedigardens")!) {
                    Text("auth.badurl.racewaycta", bundle: .module)
                }
                Button {
                    Task { await flow.emit(.reset) }
                } label: {
                    Text("OK")
                }.keyboardShortcut(.defaultAction)
            } message: {
                Text(domainValidationErrorTitle)
            }
    }

    public func stateChanged(_ state: AuthenticationGate.State) {
        switch state {
        case .openAuth(_, let callback):
            self.callbackUrl = callback
            self.displayAuthenticationDialog = true
            self.domainValidationErrorTitle = ""
        case .error(let cause):
            if cause is DomainValidationError {
                self.displayDomainValidationError = true
            }
            self.domainValidationErrorTitle = (cause as? DomainValidationError)?.message ?? cause.localizedDescription
        default:
            self.domainValidationErrorTitle = ""
        }
    }

    /// The authentication button.
    private var authForm: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                AuthenticationGateTextField(focusedDomainEntry: $focusedDomainEntry) { domain in
                    Task {
                        await flow.emit(.edit(domain: domain))
                    }
                }
                .padding(.horizontal)
                Button {
                    Task {
                        await flow.emit(.getAuthorizationToken)
                    }
                } label: {
                    Text("auth.login.button", bundle: .module)
                        .font(.system(.title3, design: .rounded))
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .controlSize(.large)
            }
            HStack {
                Text("auth.footnote", bundle: .module)
                    .foregroundColor(.secondary)
                Link(destination: URL(string: "https://joinmastodon.org/servers")!) {
                    Text("auth.footnote.create", bundle: .module)
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
                AuthenticationGateHeaderView(compact: focusedDomainEntry,
                                             alignment: .leading)
                Text("auth.startinfo", bundle: .module)
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
                AuthenticationGateHeaderView(compact: focusedDomainEntry,
                                             alignment: .trailing)
                Text("auth.startinfo", bundle: .module)
                    .font(.title3)
            }
            .frame(maxWidth: 450)
            .padding()
            authForm
                .frame(maxWidth: 450)
        }
    }
}

struct AuthenticationGateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationGateView()
            .environment(\.locale, Locale(identifier: "en"))
    }
}
