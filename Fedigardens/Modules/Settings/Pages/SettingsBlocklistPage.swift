//
//  SettingsBlocklistPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/22/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import SwiftUI
import Bunker

struct SettingsBlocklistPage: View {
    @StateObject private var viewModel = SettingsBlocklistViewModel()
    @ScaledMetric private var size = 1.0
    var body: some View {
        Group {
            switch viewModel.layoutState {
            case .initial:
                ProgressView()
            case .loading:
                List {
                    ForEach(0..<7) { _ in
                        Label("example.domain", systemImage: "building.2")
                            .labelStyle(.settings(color: .red, size: size))
                    }
                    .redacted(reason: .placeholder)
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .font(.largeTitle)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            case .loaded:
                loadedContent
            case .errored(let message):
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text("settings.blocklist.fetcherror")
                        .font(.headline)
                        .bold()
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("settings.section.blocklist")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(), value: viewModel.blockedServers)
        .animation(.spring(), value: viewModel.layoutState)
        .onAppear {
            Task {
                await viewModel.getBlockedServers()
                await viewModel.getInstanceWideBlocks()
            }
        }
        .refreshable {
            Task {
                await viewModel.getBlockedServers()
                await viewModel.getInstanceWideBlocks()
            }
        }
        .toolbar {
            Button {
                viewModel.shouldDisplayInsertionRequest.toggle()
            } label: {
                Label("settings.blocklist.blockaction", systemImage: "plus")
            }
            if viewModel.blockedServers.isNotEmpty {
                EditButton()
            }
        }
        .alert("settings.blocklist.blockaction", isPresented: $viewModel.shouldDisplayInsertionRequest) {
            TextField("example.domain", text: $viewModel.requestedDomainInsertionText)
            Button {
                Task { await viewModel.insertBlockedServer() }
            } label: {
                Text("settings.blocklist.block")
            }
            Button(role: .cancel) {
                viewModel.shouldDisplayInsertionRequest = false
            } label: {
                Text("general.cancel")
            }
        } message: {
            Text("settings.blocklist.blockmessage")
        }
    }

    private var loadedContent: some View {
        List {
            if viewModel.blockedServers.isNotEmpty {
                Section {
                    ForEach(viewModel.blockedServers, id: \.self) { blockedServer in
                        Label(blockedServer, systemImage: "building.2")
                            .labelStyle(.settings(color: .red, size: size))
                    }
                    .onDelete { offsets in
                        viewModel.deleteBlockedServers(at: offsets)
                    }
                }
            } else {
                emptyContent
            }

            if viewModel.instanceBlocks.isNotEmpty {
                Section {
                    NavigationLink("settings.blocklist.instancewideprompt") {
                        SettingsInstanceBlocklistPage(domainBlocks: viewModel.instanceBlocks)
                    }
                    .disabled(viewModel.instanceBlocks.isEmpty)
                } footer: {
                    Text("settings.blocklist.admin")
                }
            }
        }
    }

    private var emptyContent: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "building.2")
                        .font(.largeTitle)
                    Text("settings.blocklist.empty")
                        .font(.headline)
                        .bold()
                    Text("settings.blocklist.emptydetail")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 16, leading: 0, bottom: 16, trailing: 0))
        }
    }
}

struct SettingsBlocklistPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsBlocklistPage()
        }
    }
}
