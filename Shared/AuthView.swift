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

    @ObservedObject private var chicaAuth: Chica.OAuth = Chica.OAuth.shared
    @State private var showAuthDialog: Bool = false

    var body: some View {
        ZStack {
            pinstripes
                .edgesIgnoringSafeArea(.all)
            Group {
                if horizontalSizeClass == .compact {
                    compactLayout
                } else {
                    regularLayout
                }
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
        }
    }

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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {

                } label: {
                    Label("general.feedback", systemImage: "exclamationmark.bubble")
                }
            }
        }
    }

    private var compactLayout: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 32) {
                welcomeHeader(alignment: .leading)
                Text("auth.startinfo")
                    .font(.title3)
            }
            .padding()
            Spacer()
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
        .frame(maxWidth: .infinity)

    }

    private var regularLayout: some View {
        HStack(spacing: 8) {
            VStack(alignment: .trailing, spacing: 32) {
                welcomeHeader(alignment: .trailing)
                Text("auth.startinfo")
                    .font(.title3)
            }
            .frame(maxWidth: 450)
            .padding()
            VStack(spacing: 8) {
                Button {
                    showAuthDialog.toggle()
                } label: {
                    Text("auth.login.button")
                        .font(.title3)
                        .bold()
                        .frame(width: 300)
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
            .frame(maxWidth: 450)
        }
//        .frame(maxWidth: 900)
    }

    private var pinstripes: some View {
        GeometryReader { geometry in
            let halfHeight = (geometry.size.height / 2) - 64

            #if os(iOS)
            let endPoint = horizontalSizeClass == .compact
                ? geometry.size.width / 6
                : geometry.size.width / 2
            #else
            let endPoint = geometry.size.width / 2
            #endif

            ZStack {
                Path { path in
                    path.move(to: .init(x: geometry.size.width, y: 0))
                    path.addLine(to: .init(x: endPoint, y: 0))
                    path.addLine(to: .init(x: geometry.size.width, y: halfHeight))
                }
                .fill(Color.accentColor)
                Path { path in
                    path.move(to: .init(x: geometry.size.width, y: 0))
                    path.addLine(to: .init(x: endPoint, y: 0))
                    path.addLine(to: .init(x: geometry.size.width, y: halfHeight - 100))
                }
                .fill(.blue)
                Path { path in
                    path.move(to: .init(x: geometry.size.width, y: 0))
                    path.addLine(to: .init(x: endPoint, y: 0))
                    path.addLine(to: .init(x: geometry.size.width, y: halfHeight - 200))
                }
                .fill(.yellow)
            }
        }
    }

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

}

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
