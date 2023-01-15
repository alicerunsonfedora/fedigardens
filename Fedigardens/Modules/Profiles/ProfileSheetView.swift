//
//  ProfileSheetView.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/14/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Alice

struct ProfileSheetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ProfileSheetViewModel()
    var profile: Account

    var body: some View {
        NavigationStack {
            List {
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            AccountImage(author: profile)
                                .profileSize(.xlarge)
                            Text(profile.getAccountName())
                                .font(.system(.largeTitle, design: .rounded))
                                .bold()
                            Text("@\(profile.acct)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    HStack {
                        cell(
                            systemName: "person.2.fill",
                            key: "profile.followers",
                            value: "\(profile.followersCount)"
                        )
                        cell(
                            systemName: "person.3.fill",
                            key: "profile.following",
                            value: "\(profile.followingCount)"
                        )
                        cell(
                            systemName: "square.and.pencil",
                            key: "profile.statusescount",
                            value: "\(profile.statusesCount)"
                        )
                    }
                    Text(profile.note.attributedHTML())
                        .font(.subheadline)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 2, leading: 0, bottom: 2, trailing: 0))

                Section {
                    ForEach(profile.fields) { field in
                        LabeledContent(field.name) {
                            Text(field.value.attributedHTML())
                        }
                        .listRowBackground(
                            field.value == profile.verifiedDomain()
                                ? Color.green.opacity(0.2)
                                : Color(uiColor: .systemBackground)
                        )
                        .tint(
                            field.value == profile.verifiedDomain()
                            ? Color.green
                            : Color.accentColor
                        )
                    }
                }

                statusArea

            }
            .listStyle(.insetGrouped)
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Label("general.done", systemImage: "xmark")
                }
                .labelStyle(.titleOnly)
            }
        }
        .animation(.spring(), value: viewModel.layoutState)
        .onAppear {
            Task {
                viewModel.profile = profile
                await viewModel.fetchStatuses()
            }
        }
    }

    private func cell(systemName: String, key: LocalizedStringKey, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: systemName)
                .foregroundColor(.accentColor)
            VStack {
                Text(value)
                    .font(.headline)
                Text(key)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: .systemBackground)
                .cornerRadius(10)
        )
    }

    private var statusArea: some View {
        Group {
            switch viewModel.layoutState {
            case .initial, .loading:
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            case .loaded:
                Section {
                    ForEach(viewModel.statuses, id: \.uuid) { status in
                        StatusView(status: status)
                            .lineLimit(3)
                            .profilePlacement(.hidden)
                            .datePlacement(.automatic)
                    }
                } header: {
                    Text("profile.activity")
                }
            case .errored(let message):
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(.largeTitle, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(message)
                        .font(.title3)
                }
            }
        }
    }
}

struct ProfileSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileSheetView(profile: MockData.profile!)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
