//
//  SettingsInstanceBlocklistPage.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 2/12/23.
//

import SwiftUI
import Alice
import Bunker

struct SettingsInstanceBlocklistPage: View {
    var domainBlocks: [DomainBlock]
    @ScaledMetric private var size = 1.0

    private var silenced: [DomainBlock] {
        domainBlocks.filter { $0.severity == .silence }
    }

    private var suspended: [DomainBlock] {
        domainBlocks.filter { $0.severity == .suspend }
    }

    var body: some View {
        List {
            if silenced.isNotEmpty {
                Section {
                    ForEach(silenced) { blockedServer in
                        cell(for: blockedServer)
                    }
                } header: {
                    Text("settings.blocklist.silenced")
                }
            }

            if suspended.isNotEmpty {
                Section {
                    ForEach(suspended) { blockedServer in
                        cell(for: blockedServer)
                    }
                } header: {
                    Text("settings.blocklist.suspended")
                }
            }
        }
        .tint(.red)
        .navigationTitle("settings.blocklist.instancewide")
    }

    func cell(for domainBlock: DomainBlock) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(domainBlock.domain)
                    .font(.headline)
                    .bold()
                Text(domainBlock.comment ?? "settings.blocklist.nocomment".localized())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: domainBlock.severity == .suspend ? "hand.raised.square" : "speaker.slash.fill")
                .font(.headline)
        }
    }
}
